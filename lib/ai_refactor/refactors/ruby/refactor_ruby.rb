# frozen_string_literal: true

module AIRefactor
  module Refactors
    module Ruby
      class RefactorRuby < Custom
        def run
          logger.verbose "Custom refactor to #{input_file}... (using user supplied prompt #{prompt_file_path})"
          logger.verbose "Write output to #{output_file_path}..." if output_file_path

          begin
            output_content = process!(strip_ticks: true)
          rescue => e
            logger.error "Failed to process #{input_file}: #{e.message}"
            return false
          end

          return false unless output_content

          output_file_path ? true : output_content
        end

        def self.description
          "Generic refactor using user supplied prompt (assumes Ruby code generation)"
        end
      end
    end
  end
end
