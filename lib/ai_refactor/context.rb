# frozen_string_literal: true

module AIRefactor
  class Context
    def initialize(files:, text:, logger:)
      @files = files
      @text = text
      @logger = logger
    end

    def prepare_context
      context = read_contexts&.compact
      file_context = (context && context.size.positive?) ? "Here is some related files:\n\n#{context.join("\n")}" : ""
      if @text.nil? || @text.empty?
        file_context
      else
        "\n#{file_context}\n\n#{@text}\n"
      end
    end

    private

    def read_contexts
      @files&.map do |file|
        unless File.exist?(file)
          @logger.warn "Context file #{file} does not exist"
          next
        end
        "#---\n# File '#{file}':\n\n```#{File.read(file)}```\n"
      end
    end
  end
end
