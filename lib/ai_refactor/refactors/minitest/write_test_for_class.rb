# frozen_string_literal: true

module AIRefactor
  module Refactors
    module Minitest
      class WriteTestForClass < BaseRefactor
        def run
          logger.verbose "'Write minitest test' refactor for #{input_file}..."
          logger.verbose "Write output to #{output_file_path}..." if output_file_path

          begin
            output_content = process!
          rescue => e
            logger.error "Failed to process #{input_file}: #{e.message}"
            return false
          end

          return false unless output_file_path

          logger.verbose "Generated #{output_file_path} from #{input_file} ..." if output_content

          minitest_runner = AIRefactor::TestRunners::MinitestRunner.new(output_file_path, command_template: "bundle exec ruby __FILE__")

          logger.verbose "Run generated test file #{output_file_path} (#{minitest_runner.command})..."
          test_run = minitest_runner.run

          if test_run.failed?
            logger.warn "#{input_file} was translated to #{output_file_path} but the resulting test is failing..."
            logger.error "Failed to run test, exited with status #{test_run.exitstatus}. Stdout: #{test_run.stdout}\n\nStderr: #{test_run.stderr}\n\n"
            logger.error "New test failed!", bold: true
            self.failed_message = "Generated test file failed to run correctly"
            return false
          end

          logger.verbose "\nNew test file ran and returned the following results:"
          logger.verbose ">> Runs: #{test_run.example_count}, Failures: #{test_run.failure_count}, Skips: #{test_run.pending_count}\n"

          output_file_path ? true : output_content
        end

        def self.description
          "Write a minitest test for a class"
        end

        def default_output_path
          File.join("test", input_file.gsub(/\.rb$/, "_test.rb"))
        end
      end
    end
  end
end
