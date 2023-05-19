# frozen_string_literal: true

module AIRefactor
  module Tests
    class TestRunDiffReport
      def initialize(previous_test_run_result, test_run_result)
        @current = test_run_result
        @previous = previous_test_run_result
      end

      def no_differences?
        @current.example_count == @previous.example_count && @current.failure_count == @previous.failure_count && @current.pending_count == @previous.pending_count
      end

      def diff
        report = ""
        if @current.example_count != @previous.example_count
          report += "Example count mismatch: #{@current.example_count} != #{@previous.example_count}"
        end
        if @current.failure_count != @previous.failure_count
          report += "Failure count mismatch: #{@current.failure_count} != #{@previous.failure_count}"
        end
        if @current.pending_count != @previous.pending_count
          report += "Pending count mismatch: #{@current.pending_count} != #{@previous.pending_count}"
        end
        report
      end
    end
  end
end
