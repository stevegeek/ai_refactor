# frozen_string_literal: true

require "openai"
require "json"

module AIRefactor
  class FileProcessor
    attr_reader :file_path, :output_path, :logger

    def initialize(input_path:, prompt_file_path:, ai_client:, logger:, output_path: nil)
      @file_path = input_path
      @prompt_file_path = prompt_file_path
      @ai_client = ai_client
      @logger = logger
      @output_path = output_path
    end

    def output_exists?
      return false unless output_path
      File.exist?(output_path)
    end

    def process!(options)
      logger.debug("Processing #{file_path} with prompt in #{@prompt_file_path}")
      prompt = File.read(@prompt_file_path)
      input = File.read(@file_path)
      messages = [
        {role: "system", content: prompt},
        {role: "user", content: "Convert: ```#{input}```"}
      ]
      content, finished_reason, usage = generate_next_message(messages, prompt, options, options[:ai_max_attempts] || 3)

      content = if content && content.length > 0
        processed = block_given? ? yield(content) : content
        if output_path
          File.write(output_path, processed)
          logger.verbose "Wrote output to #{output_path}..."
        end
        processed
      end

      [content, finished_reason, usage]
    end

    private

    def generate_next_message(messages, prompt, options, attempts_left)
      logger.verbose "Generate AI output. Generation attempts left: #{attempts_left}"
      logger.debug "Options: #{options.inspect}"
      logger.debug "Messages: #{messages.inspect}"

      response = @ai_client.chat(
        parameters: {
          model: options[:ai_model] || "gpt-3.5-turbo",
          messages: messages,
          temperature: options[:ai_temperature] || 0.7,
          max_tokens: options[:ai_max_tokens] || 1500
        }
      )

      if response["error"]
        raise StandardError.new("OpenAI error: #{response["error"]["type"]}: #{response["error"]["message"]} (#{response["error"]["code"]})")
      end

      content = response.dig("choices", 0, "message", "content")
      finished_reason = response.dig("choices", 0, "finish_reason")

      if finished_reason == "length" && attempts_left > 0
        generate_next_message(messages + [
          {role: "assistant", content: content},
          {role: "user", content: "Continue"}
        ], prompt, options, attempts_left - 1)
      else
        previous_messages = messages.filter { |m| m[:role] == "assistant" }.map { |m| m[:content] }.join
        content = if previous_messages.length > 0
          content ? previous_messages + content : previous_messages
        else
          content
        end
        [content, finished_reason, response["usage"]]
      end
    end
  end
end
