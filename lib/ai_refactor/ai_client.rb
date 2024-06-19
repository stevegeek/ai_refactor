# frozen_string_literal: true

module AIRefactor
  class AIClient
    def initialize(platform: "openai", model: "gpt-4-turbo", temperature: 0.7, max_tokens: 1500, timeout: 60, verbose: false)
      @platform = platform
      @model = model
      @temperature = temperature
      @max_tokens = max_tokens
      @timeout = timeout
      @verbose = verbose
      @client = configure
    end

    def generate!(messages)
      finished_reason, content, response = case @platform
      when "openai"
        openai_parse_response(
          @client.chat(
            parameters: {
              messages: messages,
              model: @model,
              temperature: @temperature,
              max_tokens: @max_tokens
            }
          )
        )
      when "anthropic"
        anthropic_parse_response(
          @client.messages(
            parameters: {
              system: messages.find { |m| m[:role] == "system" }&.fetch(:content, nil),
              messages: messages.select { |m| m[:role] != "system" },
              model: @model,
              max_tokens: @max_tokens
            }
          )
        )
      else
        raise "Invalid platform: #{@platform}"
      end
      yield finished_reason, content, response
    end

    private

    def configure
      case @platform
      when "openai"
        ::OpenAI::Client.new(
          access_token: ENV.fetch("OPENAI_API_KEY"),
          organization_id: ENV.fetch("OPENAI_ORGANIZATION_ID", nil),
          request_timeout: @timeout,
          log_errors: @verbose
        )
      when "anthropic"
        ::Anthropic::Client.new(
          access_token: ENV.fetch("ANTHROPIC_API_KEY"),
          request_timeout: @timeout
        )
      else
        raise "Invalid platform: #{@platform}"
      end
    end

    def openai_parse_response(response)
      if response["error"]
        raise StandardError.new("OpenAI error: #{response["error"]["type"]}: #{response["error"]["message"]} (#{response["error"]["code"]})")
      end

      content = response.dig("choices", 0, "message", "content")
      finished_reason = response.dig("choices", 0, "finish_reason")
      [finished_reason, content, response]
    end

    def anthropic_parse_response(response)
      if response["error"]
        raise StandardError.new("Anthropic error: #{response["error"]["type"]}: #{response["error"]["message"]}")
      end

      content = response.dig("content", 0, "text")
      finished_reason = response["stop_reason"] == "max_tokens" ? "length" : response["stop_reason"]
      [finished_reason, content, response]
    end
  end
end
