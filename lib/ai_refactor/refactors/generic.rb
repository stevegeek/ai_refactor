# frozen_string_literal: true

module AIRefactor
  module Refactors
    class Generic
      attr_reader :input_file, :options, :logger

      def initialize(input_file, options, logger)
        @input_file = input_file
        @options = options
        @logger = logger
      end

      def run
        raise "Not implemented"
      end

      private

      def ai_client
        @ai_client ||= OpenAI::Client.new
      end

      class << self
        def command_line_options
          []
        end

        def refactor_name
          name.split("::")
            .last
            .gsub(/::/, "/")
            .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
            .gsub(/([a-z\d])([A-Z])/, '\1_\2')
            .tr("-", "_")
            .downcase
        end

        def prompt_file_path
          File.join(File.dirname(File.expand_path(__FILE__)), "prompts", "#{refactor_name}.md")
        end
      end
    end
  end
end
