# frozen_string_literal: true

require "fileutils"
require "openai"
require "json"

module AIRefactor
  class FileProcessor
    attr_reader :input_file_path, :output_path, :logger, :options

    def initialize(prompt:, ai_client:, logger:, output_path: nil, options: {})
      @prompt = prompt
      @ai_client = ai_client
      @logger = logger
      @output_path = output_path
      @options = options
    end

    def output_exists?
      return false unless output_path
      File.exist?(output_path)
    end

    def process!
      logger.debug("Processing #{@prompt.input_file_path} with prompt in #{options.prompt_file_path}")
      logger.debug("Options: #{options.inspect}")
      messages = @prompt.chat_messages
      if options[:review_prompt]
        logger.info "Review prompt:\n"
        messages.each do |message|
          logger.info "\n-- Start of prompt for Role #{message[:role]} --\n"
          logger.info message[:content]
          logger.info "\n-- End of prompt for Role #{message[:role]} --\n"
        end
        return [nil, "Skipped as review prompt was requested", nil]
      end

      content, finished_reason, usage = generate_next_message(messages, options, ai_max_attempts)

      content = if content && content.length > 0
        processed = block_given? ? yield(content) : content
        if output_path
          write_output(output_path, processed)
          logger.verbose "Wrote output to #{output_path}..."
        end
        processed
      end

      [content, finished_reason, usage]
    end

    private

    def ai_max_attempts
      options[:ai_max_attempts] || 1
    end

    def generate_next_message(messages, options, attempts_left)
      logger.verbose "Generate AI output. Generation attempts left: #{attempts_left}"
      logger.debug "Options: #{options.inspect}"
      logger.debug "Messages: #{messages.inspect}"

      response = @ai_client.chat(
        parameters: {
          model: options[:ai_model] || "gpt-4-turbo-preview",
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
        ], options, attempts_left - 1)
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

    def write_output(output_path, processed)
      dir = File.dirname(output_path)
      FileUtils.mkdir_p(dir) unless File.directory?(dir)
      File.write(output_path, processed)
    end
  end
end
