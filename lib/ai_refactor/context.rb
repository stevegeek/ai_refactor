# frozen_string_literal: true

module AIRefactor
  class Context
    def initialize(files:, logger:)
      @files = files
      @logger = logger
    end

    def prepare_context
      contexts = @files&.map do |file|
        context = if File.exist?(file)
          File.read(file)
        else
          @logger.warn "Context file #{file} does not exist"
          ""
        end
        "#---\n# #{file}\n\n#{context}"
      end
      contexts&.join("\n")
    end
  end
end
