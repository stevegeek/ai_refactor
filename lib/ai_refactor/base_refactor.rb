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

    def prompt_file_path
      file = if options && options[:prompt_file_path]&.length&.positive?
        options[:prompt_file_path]
      else
        location = Module.const_source_location(self.class.name)
        File.join(File.dirname(location.first), "#{refactor_name}.md")
      end
      file.tap do |prompt|
        raise "No prompt file '#{prompt}' found for #{refactor_name}" unless File.exist?(prompt)
      end
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
        name.split("::")
          .last
          .gsub(/::/, "/")
          .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
          .gsub(/([a-z\d])([A-Z])/, '\1_\2')
          .tr("-", "_")
          .downcase
      end
    end
  end
end
