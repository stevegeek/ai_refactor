# frozen_string_literal: true

module AIRefactor
  class Context
    def initialize(files:, logger:)
      @files = files
      @logger = logger
    end

    def prepare_context
      context = read_contexts&.compact
      (context && context.size.positive?) ? "Extra context from the codebase: #{context.join("\n")}" : ""
    end

    private

    def read_contexts
      @files&.map do |file|
        unless File.exist?(file)
          @logger.warn "Context file #{file} does not exist"
          next
        end
        "#---\n# #{file}\n\n#{File.read(file)}"
      end
    end
  end
end
