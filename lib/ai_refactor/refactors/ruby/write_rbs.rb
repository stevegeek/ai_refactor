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

          if output_file_path
            steep_runner = AIRefactor::TestRunners::SteepRunner.new(input_file, command_template: options.minitest_run_command)

            logger.verbose "Run steep against generated RBS file #{output_file_path} (`#{steep_runner.command}`)..."
            test_run = steep_runner.run

            if test_run.failed?
              logger.warn "#{input_file} was translated to #{output_file_path} but the resulting RBS fails to pass a steep check..."
              logger.error "Failed to run test, exited with status #{test_run.exitstatus}. Stdout: #{test_run.stdout}\n\nStderr: #{test_run.stderr}\n\n"
              logger.error "New RBS failed!", bold: true
              self.failed_message = "Generated RBS file failed to pass checks"
              return false
            end

            logger.verbose "\nNew RBS file passed checks"
          end

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
