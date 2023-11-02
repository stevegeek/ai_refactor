# frozen_string_literal: true

module AIRefactor
  module Refactors
    class BaseRefactor
      # All subclasses must register themselves with the Registry
      def self.inherited(subclass)
        super
        Refactors.register(subclass)
      end

      def self.description
        "(No description provided)"
      end

      def self.takes_input_files?
        true
      end

      attr_reader :input_file, :options, :logger
      attr_accessor :input_content
      attr_writer :failed_message

      def initialize(input_file, options, logger)
        @input_file = input_file
        @options = options
        @logger = logger
      end

      def run
        raise NotImplementedError
      end

      def failed_message
        @failed_message || "Reason not specified"
      end

      private

      def file_processor
        context = ::AIRefactor::Context.new(files: options[:context_file_paths], text: options[:context_text], logger: logger)
        prompt = ::AIRefactor::Prompt.new(input_content: input_content, input_path: input_file, output_file_path: output_file_path, prompt: prompt_input, context: context, logger: logger, prompt_footer: prompt_footer, options: options)
        AIRefactor::FileProcessor.new(prompt: prompt, ai_client: ai_client, output_path: output_file_path, logger: logger, options: options)
      end

      def process!(strip_ticks: true)
        processor = file_processor

        if processor.output_exists?
          return false unless overwrite_existing_output?(output_file_path)
        end

        logger.verbose "Processing #{input_file}..."

        begin
          output_content, finished_reason, usage = processor.process! do |content|
            if block_given?
              yield content
            elsif strip_ticks
              content.gsub("```ruby", "").gsub("```", "")
            else
              content
            end
          end

          logger.verbose "AI finished, with reason '#{finished_reason}'..."
          logger.verbose "Used tokens: #{usage["total_tokens"]}".colorize(:light_black) if usage
          if finished_reason == "length"
            logger.warn "Translation may contain an incomplete output as the max token length was reached. You can try using the '--continue' option next time to increase the length of generated output."
          end

          if !output_content || output_content.length == 0
            logger.warn "Skipping #{input_file}, no translated output..."
            logger.error "Failed to translate #{input_file}, finished reason #{finished_reason}"
            self.failed_message = "AI conversion failed, no output was generated"
            raise NoOutputError, "No output"
          end

          output_content
        rescue => e
          logger.error "Request to AI failed: #{e.message}"
          logger.warn "Skipping #{input_file}..."
          self.failed_message = "Request to OpenAI failed"
          raise e
        end
      end

      def overwrite_existing_output?(output_path)
        overwrite = options && options[:overwrite]&.downcase
        answer = if ["y", "n"].include? overwrite
          overwrite
        else
          logger.info "Do you wish to overwrite #{output_path}? (y/n)"
          $stdin.gets.chomp.downcase
        end
        if answer == "y"
          logger.verbose "Overwriting #{output_path}..."
          return true
        end
        logger.warn "Skipping #{input_file}..."
        self.failed_message = "Skipped as output file already exists"
        false
      end

      def prompt_template_for_refactor
        location = Module.const_source_location(::AIRefactor::Refactors::BaseRefactor.name)
        File.join(File.dirname(location.first), "#{refactor_name}.md")
      end

      def prompt_template_for_refactor?
        File.exist?(prompt_template_for_refactor)
      end

      def user_provided_prompt_template?
        options[:prompt_file_path]&.length&.positive?
      end

      def prompt_from_file?
        user_provided_prompt_template? || prompt_template_for_refactor?
      end

      def user_provided_prompt?
        options[:prompt]&.length&.positive?
      end

      def prompt_input
        if user_provided_prompt_template?
          file = options[:prompt_file_path]
          raise "No prompt file '#{file}' found. Check prompt_file_path is valid" unless File.exist?(file)
          File.read(file)
        else
          file = prompt_template_for_refactor
          if File.exist?(file)
            File.read(file)
          elsif user_provided_prompt?
            options[:prompt]
          else
            raise "No prompt was provided. Please provide one with the --prompt option or with a command file."
          end
        end
      end

      def prompt_footer
        options[:prompt] if user_provided_prompt? && prompt_from_file?
      end

      def output_file_path
        @output_file_path ||= determine_output_file_path
      end

      def determine_output_file_path
        return output_file_path_from_template if output_template_path

        path = options[:output_file_path]
        return default_output_path unless path

        if path == true
          input_file
        else
          path
        end
      end

      def default_output_path
        nil
      end

      def output_template_path
        options[:output_template_path]
      end

      def output_file_path_from_template
        path = AIRefactor::TemplatedPath.new(input_file, refactor_name, output_template_path).generate
        raise "Output template could not be used" unless path.length.positive?
        path
      end

      def ai_client
        @ai_client ||= OpenAI::Client.new
      end

      def refactor_name
        self.class.refactor_name
      end

      class << self
        def command_line_options
          []
        end

        def refactor_name
          name.gsub("AIRefactor::Refactors::", "")
            .gsub(/::/, "/")
            .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
            .gsub(/([a-z\d])([A-Z])/, '\1_\2')
            .tr("-", "_")
            .downcase
        end
      end
    end
  end
end
