# frozen_string_literal: true

module AIRefactor
  class Context
    def initialize(files:, logger:)
      @files = files
      @logger = logger
    end

    def prepare_context
      context = read_contexts
      context ? "Extra context from the codebase: #{context.join("\n")}" : ""
    end

    private

    def read_contexts
      @files&.map do |file|
        context = if File.exist?(file)
          File.read(file)
        else
          @logger.warn "Context file #{file} does not exist"
          ""
        end
        "#---\n# #{file}\n\n#{context}"
      end
    end
  end
end
