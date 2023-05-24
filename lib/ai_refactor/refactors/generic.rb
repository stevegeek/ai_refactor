# frozen_string_literal: true

module AIRefactor
  module Refactors
    class Generic < BaseRefactor
      def run
        logger.verbose "Generic refactor to #{input_file}... (using user supplied prompt #{prompt_file_path})"

        processor = AIRefactor::FileProcessor.new(
          input_path: input_file,
          prompt_file_path: prompt_file_path,
          ai_client: ai_client,
          logger: logger
        )

        logger.verbose "Converting #{input_file}..."

        begin
          output_content, finished_reason, usage = processor.process!(options)
        rescue => e
          logger.error "Request to OpenAI failed: #{e.message}"
          logger.warn "Skipping #{input_file}..."
          self.failed_message = "Request to OpenAI failed"
          return false
        end

        logger.verbose "OpenAI finished, with reason '#{finished_reason}'..."
        logger.verbose "Used tokens: #{usage["total_tokens"]}".colorize(:light_black) if usage

        if finished_reason == "length"
          logger.warn "Translation may contain an incomplete output as the max token length was reached. You can try using the '--continue' option next time to increase the length of generated output."
        end

        if !output_content || output_content.length == 0
          logger.warn "Skipping #{input_file}, no translated output..."
          logger.error "Failed to translate #{input_file}, finished reason #{finished_reason}"
          self.failed_message = "AI conversion failed, no output was generated"
          return false
        end

        output_content
      end

      private

      def prompt_file_path
        specified_prompt_path = options[:prompt_file_path]
        if specified_prompt_path&.length&.positive?
          if File.exist?(specified_prompt_path)
            return specified_prompt_path
          else
            logger.error "No prompt file '#{specified_prompt_path}' found"
          end
        else
          logger.error "No prompt file was specified!"
        end
        exit 1
      end

      class << self
        def prompt_file_path
          raise "Generic refactor requires prompt file to be user specified."
        end
      end
    end
  end
end
