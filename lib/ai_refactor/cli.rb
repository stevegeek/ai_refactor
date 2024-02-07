# frozen_string_literal: true

require "readline"

module AIRefactor
  class Cli
    class << self
      def load_options_from_config_file
        # Load config from ~/.ai_refactor or .ai_refactor
        home_config_file_path = File.expand_path("~/.ai_refactor")
        local_config_file_path = File.join(Dir.pwd, ".ai_refactor")

        config_file_path = if File.exist?(local_config_file_path)
          local_config_file_path
        elsif File.exist?(home_config_file_path)
          home_config_file_path
        end
        return unless config_file_path

        config_string = File.read(config_file_path)
        config_lines = config_string.split(/\n+/).reject { |s| s =~ /\A\s*#/ }.map(&:strip)
        config_lines.flat_map(&:shellsplit)
      end

      def request_text_input(prompt)
        puts prompt
        gets.chomp
      end

      def request_input_with_autocomplete(prompt, completion_list)
        Readline.completion_append_character = nil
        Readline.completion_proc = proc do |str|
          completion_list.grep(/^#{Regexp.escape(str)}/)
        end
        Readline.readline(prompt, true)
      end

      def request_file_inputs(prompt, multiple: true)
        Readline.completion_append_character = multiple ? " " : nil
        Readline.completion_proc = Readline::FILENAME_COMPLETION_PROC

        paths = Readline.readline(prompt, true)
        multiple ? paths.gsub(/[^\\] /, ",") : paths
      end

      def request_switch(prompt)
        (Readline.readline(prompt, true) =~ /^y/i) ? true : false
      end
    end

    def initialize(configuration, logger:)
      @configuration = configuration
      @logger = logger
    end

    attr_reader :configuration, :logger

    def refactoring_type
      configuration.refactor || raise(StandardError, "No refactor provided")
    end

    def inputs
      configuration.input_file_paths
    end

    def valid?
      return false unless refactorer
      inputs_valid = refactorer.takes_input_files? ? !(inputs.nil? || inputs.empty?) : true
      AIRefactor::Refactors.supported?(refactoring_type) && inputs_valid
    end

    def run
      return false unless valid?

      OpenAI.configure do |config|
        config.access_token = ENV.fetch("OPENAI_API_KEY")
        config.organization_id = ENV.fetch("OPENAI_ORGANIZATION_ID", nil)
        config.request_timeout = configuration.ai_timeout || 240
      end

      if refactorer.takes_input_files?
        expanded_inputs = inputs.map do |path|
          File.exist?(path) ? path : Dir.glob(path)
        end.flatten

        logger.info "AI Refactor #{expanded_inputs.size} files(s)/dir(s) '#{expanded_inputs}' with #{refactorer.refactor_name} refactor\n"
        logger.info "====================\n"
        if configuration.description
          logger.info "Description: #{configuration.description}\n"
        end

        return_values = expanded_inputs.map do |file|
          logger.info "Processing #{file}..."

          refactor = refactorer.new(file, configuration, logger)
          refactor_returned = refactor.run
          failed = refactor_returned == false
          if failed
            logger.warn "Refactor failed on #{file}\nFailed due to: #{refactor.failed_message}\n"
          else
            logger.success "Refactor succeeded on #{file}\n"
            if refactor_returned.is_a?(String)
              logger.info "Refactor #{file} output:\n\n#{refactor_returned}\n\n"
            end
          end
          failed ? [file, refactor.failed_message] : true
        end

        if return_values.all?(true)
          logger.success "All files processed successfully!"
        else
          files = return_values.select { |v| v != true }
          logger.warn "Some files failed to process:\n#{files.map { |f| "#{f[0]} :\n > #{f[1]}" }.join("\n")}"
        end

        logger.info "Done processing all files!"
      else
        name = refactorer.refactor_name
        logger.info "AI Refactor - #{name} refactor\n"
        logger.info "====================\n"
        refactor = refactorer.new(nil, configuration, logger)
        refactor_returned = refactor.run
        failed = refactor_returned == false
        if failed
          logger.warn "Refactor failed with #{name}\nFailed due to: #{refactor.failed_message}\n"
        else
          logger.success "Refactor succeeded with #{name}\n"
          if refactor_returned.is_a?(String)
            logger.info "Refactor output:\n\n#{refactor_returned}\n\n"
          end
        end
      end
    end

    private

    def refactorer
      @refactorer ||= AIRefactor::Refactors.get(refactoring_type)
    end
  end
end
