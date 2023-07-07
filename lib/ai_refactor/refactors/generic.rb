# frozen_string_literal: true

module AIRefactor
  module Refactors
    class Generic < BaseRefactor
      def run
        logger.verbose "Generic refactor to #{input_file}... (using user supplied prompt #{prompt_file_path})"
        logger.verbose "Write output to #{output_file_path}..." if output_file_path

        context = ::AIRefactor::Context.new(files: options[:context_file_paths], logger: logger)
        prompt = ::AIRefactor::Prompt.new(input_path: input_file, prompt_file_path: prompt_file_path, context: context, logger: logger, options: options)
        processor = AIRefactor::FileProcessor.new(prompt: prompt, ai_client: ai_client, logger: logger, output_path: output_file_path, options: options)

        if processor.output_exists?
          return false unless overwrite_existing_output?(output_file_path)
        end

        logger.verbose "Converting #{input_file}..."

        begin
          output_content, finished_reason, usage = processor.process!
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

        output_file_path ? true : output_content
      end

      private

      def output_file_path
        return output_file_path_from_template if output_template_path

        path = options[:output_file_path]
        return unless path

        if path == true
          input_file
        else
          path
        end
      end

      def output_template_path
        options[:output_template_path]
      end

      def output_file_path_from_template
        path = output_template_path.gsub("[FILE]", File.basename(input_file))
          .gsub("[NAME]", File.basename(input_file, ".*"))
          .gsub("[DIR]", File.dirname(input_file))
          .gsub("[REFACTOR]", self.class.refactor_name)
          .gsub("[EXT]", File.extname(input_file))
        raise "Output template could not be used" unless path.length.positive?
        path
      end

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
        def command_line_options
          [
            {
              key: :output_file_path,
              long: "--output [FILE]",
              type: String,
              help: "Write output to file instead of stdout. If no path provided will overwrite input file (will prompt to overwrite existing files)"
            },
            {
              key: :output_template_path,
              long: "--output-template TEMPLATE",
              type: String,
              help: "Write outputs to files instead of stdout. The template is used to create the output name, where the it can have substitutions, '[FILE]', '[NAME]', '[DIR]', '[REFACTOR]' & '[EXT]'. Eg `[DIR]/[NAME]_[REFACTOR][EXT]` (will prompt to overwrite existing files)"
            }
          ]
        end
      end
    end
  end
end
