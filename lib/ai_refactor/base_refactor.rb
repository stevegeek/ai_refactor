# frozen_string_literal: true

module AIRefactor
  class BaseRefactor
    attr_reader :input_file, :options, :logger
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

    def can_overwrite_output_file?(output_path)
      logger.info "Do you wish to overwrite #{output_path}? (y/n)"
      answer = $stdin.gets.chomp
      unless answer == "y" || answer == "Y"
        logger.warn "Skipping #{input_file}..."
        self.failed_message = "Skipped as output file already exists"
        return false
      end
      true
    end

    def prompt_file_path
      self.class.prompt_file_path
    end

    def ai_client
      @ai_client ||= OpenAI::Client.new
    end

    class << self
      def command_line_options
        []
      end

      def refactor_name
        name.split("::")
          .last
          .gsub(/::/, "/")
          .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
          .gsub(/([a-z\d])([A-Z])/, '\1_\2')
          .tr("-", "_")
          .downcase
      end

      def prompt_file_path
        file = if options[:prompt_file_path]&.length&.positive?
          options[:prompt_file_path]
        else
          File.join(File.dirname(File.expand_path(__FILE__)), "prompts", "#{refactor_name}.md")
        end
        file.tap do |prompt|
          raise "No prompt file '#{prompt}' found for #{refactor_name}" unless File.exist?(prompt)
        end
      end
    end
  end
end
