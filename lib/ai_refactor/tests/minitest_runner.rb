# frozen_string_literal: true

require "open3"

module AIRefactor
  module Tests
    class MinitestRunner
      def initialize(file_path, working_dir: nil, command_template: "bundle exec rails test __FILE__")
        @file_path = file_path
        @working_dir = working_dir
        @command_template = command_template
      end

      def command
        template = @command_template.gsub("__FILE__", @file_path)
        @working_dir ? "cd #{@working_dir} && #{template}" : template
      end

      def run
        stdout, stderr, status = Open3.capture3(command)
        _matched, runs, _assertions, failures, errors, skips = stdout.match(/(\d+) runs, (\d+) assertions, (\d+) failures, (\d+) errors, (\d+) skips/).to_a
        TestRunResult.new(stdout, stderr, status, runs, failures, skips, errors)
      end
    end
  end
end
