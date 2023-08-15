# frozen_string_literal: true

module AIRefactor
  class Cli
    def initialize(refactoring_type:, inputs:, options:, logger:)
      @refactoring_type = refactoring_type
      @inputs = inputs
      @options = options
      @logger = logger
    end

    attr_reader :refactoring_type, :inputs, :options, :logger

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
        config.request_timeout = options[:ai_timeout] || 240
      end

      if refactorer.takes_input_files?
        expanded_inputs = inputs.map do |path|
          File.exist?(path) ? path : Dir.glob(path)
        end.flatten

        logger.info "AI Refactor #{expanded_inputs.size} files(s)/dir(s) '#{expanded_inputs}' with #{refactorer.refactor_name} refactor\n"
        logger.info "====================\n"

        return_values = expanded_inputs.map do |file|
          logger.info "Processing #{file}..."

          refactor = refactorer.new(file, options, logger)
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
        refactor = refactorer.new(nil, options, logger)
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
