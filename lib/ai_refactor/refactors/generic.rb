# frozen_string_literal: true

module AIRefactor
  module Refactors
    class Generic < BaseRefactor
      def run
        logger.verbose "Generic refactor to #{input_file}... (using user supplied prompt #{prompt_file_path})"
        logger.verbose "Write output to #{output_file_path}..." if output_file_path

        output_content = process!

        return false unless output_content

        output_file_path ? true : output_content
      end

      private

      def prompt_file_path
        specified_prompt_path = options[:prompt_file_path]
        if specified_prompt_path&.length&.positive?
          if File.exist?(specified_prompt_path)
            return specified_prompt_path
          else
            logger.error "No prompt file '#{specified_prompt_path}' found"
          end
        else
          logger.error "No prompt file was specified!"
        end
        exit 1
      end
    end
  end
end
