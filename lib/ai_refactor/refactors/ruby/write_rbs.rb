# frozen_string_literal: true

module AIRefactor
  module Refactors
    module Ruby
      class WriteRbs < BaseRefactor
        def run
          logger.verbose "Write some RBS for #{input_file}..."
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
          "User supplied prompt to write RBS for some Ruby"
        end

        def default_output_path
          File.join("sig", input_file.gsub(/\.rb$/, ".rbs"))
        end
      end
    end
  end
end
