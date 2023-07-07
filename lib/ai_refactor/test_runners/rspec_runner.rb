# frozen_string_literal: true

require "open3"

module AIRefactor
  module TestRunners
    class RSpecRunner
      def initialize(file_path, command_template: "bundle exec rspec __FILE__")
        @file_path = file_path
        @command_template = command_template
      end

      def command
        @command_template.gsub("__FILE__", @file_path)
      end

      def run
        stdout, stderr, status = Open3.capture3(command)
        _matched, example_count, failure_count = stdout.match(/(\d+) examples?, (\d+) failures?/).to_a
        pending_count = stdout.match(/(\d+) pending/)&.values_at(1) || "0"
        errored = stdout.match(/, (\d+) errors? occurred outside of examples/)&.values_at(1) || "0"
        TestRunResult.new(stdout, stderr, status, example_count, failure_count, pending_count, errored)
      end
    end
  end
end
