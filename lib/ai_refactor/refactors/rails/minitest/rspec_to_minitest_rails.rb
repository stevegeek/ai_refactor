# frozen_string_literal: true

require_relative "tests/test_run_result"
require_relative "tests/rspec_runner"
require_relative "tests/minitest_runner"
require_relative "tests/test_run_diff_report"

module AIRefactor
  module Refactors
    class RspecToMinitestRails < BaseRefactor
      def run
        spec_runner = AIRefactor::Tests::RSpecRunner.new(input_file)
        logger.verbose "Run spec #{input_file}... (#{spec_runner.command})"

        spec_run = spec_runner.run

        if spec_run.failed?
          logger.warn "Skipping #{input_file}..."
          logger.error "Failed to run #{input_file}, exited with status #{spec_run.exitstatus}. Stdout: #{spec_run.stdout}\n\nStderr: #{spec_run.stderr}\n\n"
          self.failed_message = "Failed to run RSpec file, has errors"
          return false
        end

        logger.debug "Original test run results:"
        logger.debug ">> Examples: #{spec_run.example_count}, Failures: #{spec_run.failure_count}, Pendings: #{spec_run.pending_count}"

        output_path = input_file.gsub("_spec.rb", "_test.rb").gsub("spec/", "test/")

        processor = AIRefactor::FileProcessor.new(
          prompt: ::AIRefactor::Prompt.new(input_path: input_file, prompt_file_path: prompt_file_path, diff: options[:diff]),
          output_path: output_path,
          ai_client: ai_client,
          logger: logger,
          options: options
        )

        if processor.output_exists?
          return false unless overwrite_existing_output?(output_path)
        end

        logger.verbose "Converting #{input_file}..."

        begin
          output_content, finished_reason, usage = processor.process! do |content|
            content.gsub("```", "")
          end
        rescue => e
          logger.error "Request to OpenAI failed: #{e.message}"
          logger.warn "Skipping #{input_file}..."
          self.failed_message = "Request to OpenAI failed"
          return false
        end

        logger.verbose "OpenAI finished, with reason '#{finished_reason}'..."
        logger.verbose "Used tokens: #{usage["total_tokens"]}".colorize(:light_black) if usage

        if finished_reason == "length"
          logger.warn "Translation may contain an incomplete output as the max token length was reached. You can try using the '--continue' option next time to increase the length of generated output."
          logger.warn "Continuing to test the translated file... but it is likely to fail."
        end

        if !output_content || output_content.length == 0
          logger.warn "Skipping #{input_file}, no translated output..."
          logger.error "Failed to translate #{input_file}, finished reason #{finished_reason}"
          self.failed_message = "AI conversion failed, no output was generated"
          return false
        end

        logger.verbose "Converted #{input_file} to #{output_path}..."

        minitest_runner = AIRefactor::Tests::MinitestRunner.new(processor.output_path)

        logger.verbose "Run generated test file #{output_path} (#{minitest_runner.command})..."
        test_run = minitest_runner.run

        if test_run.failed?
          logger.warn "Skipping #{input_file}..."
          logger.error "Failed to run translated #{output_path}, exited with status #{test_run.exitstatus}. Stdout: #{test_run.stdout}\n\nStderr: #{test_run.stderr}\n\n"
          logger.error "Conversion failed!", bold: true
          self.failed_message = "Generated test file failed to run correctly"
          return false
        end

        logger.debug "Translated test file results:"
        logger.debug ">> Runs: #{test_run.example_count}, Failures: #{test_run.failure_count}, Skips: #{test_run.pending_count}"

        report = AIRefactor::Tests::TestRunDiffReport.new(spec_run, test_run)

        if report.no_differences?
          logger.verbose "Done converting #{input_file} to #{output_path}..."
          logger.success "No differences found! Conversion worked!"
          true
        else
          logger.warn report.diff.colorize(:yellow)
          logger.verbose "Done converting #{input_file} to #{output_path}..."
          logger.error "Differences found! Conversion failed!", bold: true
          self.failed_message = "Generated test file run output did not match original RSpec spec run output"
          false
        end
      end
    end
  end
end
