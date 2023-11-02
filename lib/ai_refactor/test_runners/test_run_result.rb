# frozen_string_literal: true

module AIRefactor
  module TestRunners
    class TestRunResult
      attr_reader :stdout, :stderr, :example_count, :failure_count, :pending_count

      def initialize(stdout, stderr, status, example_count = 0, failure_count = 0, pending_count = 0, errored = 0)
        @stdout = stdout
        @stderr = stderr
        @status = status
        @example_count = example_count
        @failure_count = failure_count
        @pending_count = pending_count
        @errored = errored
      end

      def failed?
        return true unless @status.success?
        @errored && @errored.to_i > 0
      end

      def exitstatus
        @status.exitstatus
      end
    end
  end
end
