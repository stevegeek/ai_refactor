# frozen_string_literal: true

module AIRefactor
  module Refactors
    module Rails
      module Minitest
        class RspecToMinitest < BaseRefactor
          def run
            spec_runner = AIRefactor::TestRunners::RSpecRunner.new(input_file)
            logger.verbose "Run spec #{input_file}... (#{spec_runner.command})"

            spec_run = spec_runner.run

            if spec_run.failed?
              logger.warn "Skipping #{input_file}..."
              logger.error "Failed to run #{input_file}, exited with status #{spec_run.exitstatus}. Stdout: #{spec_run.stdout}\n\nStderr: #{spec_run.stderr}\n\n"
              self.failed_message = "Failed to run RSpec file, has errors"
              return false
            end

            logger.debug "\nOriginal test run results:"
            logger.debug ">> Examples: #{spec_run.example_count}, Failures: #{spec_run.failure_count}, Pendings: #{spec_run.pending_count}\n"

            begin
              result = process! do |content|
                content.gsub("```ruby", "").gsub("```", "")
              end
            rescue AIRefactor::NoOutputError => _e
              return false
            rescue => e
              logger.error "Failed to convert #{input_file} to Minitest, error: #{e.message}"
              return false
            end

            logger.verbose "Converted #{input_file} to #{output_file_path}..." if result

            minitest_runner = AIRefactor::TestRunners::MinitestRunner.new(output_file_path)

            logger.verbose "Run generated test file #{output_file_path} (#{minitest_runner.command})..."
            test_run = minitest_runner.run

            if test_run.failed?
              logger.warn "Skipping #{input_file}..."
              logger.error "Failed to run translated #{output_file_path}, exited with status #{test_run.exitstatus}. Stdout: #{test_run.stdout}\n\nStderr: #{test_run.stderr}\n\n"
              logger.error "Conversion failed!", bold: true
              self.failed_message = "Generated test file failed to run correctly"
              return false
            end

            logger.debug "\nTranslated test file results:"
            logger.debug ">> Runs: #{test_run.example_count}, Failures: #{test_run.failure_count}, Skips: #{test_run.pending_count}\n"

            report = AIRefactor::TestRunners::TestRunDiffReport.new(spec_run, test_run)

            if report.no_differences?
              logger.verbose "Done converting #{input_file} to #{output_file_path}..."
              logger.success "\nNo differences found! Conversion worked!"
              true
            else
              logger.warn report.diff.colorize(:yellow)
              logger.verbose "Done converting #{input_file} to #{output_file_path}..."
              logger.error "\nDifferences found! Conversion failed!", bold: true
              self.failed_message = "Generated test file run output did not match original RSpec spec run output"
              false
            end
          end

          def default_output_path
            input_file.gsub("_spec.rb", "_test.rb").gsub("spec/", "test/")
          end
        end
      end
    end
  end
end
