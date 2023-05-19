# frozen_string_literal: true

require "openai"
require "json"

module AIRefactor
  class FileProcessor
    attr_reader :file_path

    def initialize(file_path, prompt_file_path:, ai_client:, working_dir: nil)
      @file_path = file_path
      @prompt_file_path = prompt_file_path
      @ai_client = ai_client
      @working_dir = working_dir
    end

    def output_path
      @file_path.gsub("_spec.rb", "_test.rb").gsub("spec/", "test/")
    end

    def resolved_output_path
      @output_path ||= File.join(@working_dir || "", output_path)
    end

    def output_exists?
      File.exist?(resolved_output_path)
    end

    def process!(options)
      prompt = File.read(@prompt_file_path)
      input = File.read(File.join(@working_dir || "", @file_path))
      messages = [
        {role: "system", content: prompt},
        {role: "user", content: "Convert: ```#{input}```"}
      ]
      content, finished_reason, usage = generate_next_message(messages, prompt, options, options[:ai_max_attempts] || 3)

      if content && content.length > 0
        File.write(resolved_output_path, content.gsub("```", ""))
      end

      [content, finished_reason, usage]
    end

    private

    def generate_next_message(messages, prompt, options, attempts_left)
      puts "Attempts left: #{options}"
      puts attempts_left
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
