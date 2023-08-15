# frozen_string_literal: true

module AIRefactor
  module Refactors
    module Project
      class WriteChangelogFromHistory < BaseRefactor
        def self.description
          "Write changelog entries from the git history"
        end

        def self.takes_input_files?
          false
        end

        def run
          logger.verbose "Creating changelog entries for project from #{options[:git_commit_count] || 3} commits..."
          logger.verbose "Write output to #{output_file_path}..." if output_file_path

          self.input_content = `git log -#{options[:git_commit_count] || 3} --pretty=format:"%ci %d %s"`.split("\n").map { |line| "- #{line}" }.join("\n")
          logger.debug "\nInput messages: \n#{input_content}\n\n"
          begin
            output_content = process!(strip_ticks: false)
          rescue => e
            logger.error "Failed to process: #{e.message}"
            return false
          end

          return false unless output_content

          output_file_path ? true : output_content
        end

        def default_output_path
          nil
        end

        def self.command_line_options
          [
            {
              key: :git_commit_count,
              long: "--commits N",
              type: Integer,
              help: "The number of commits to analyse when creating the changelog entries (defaults to 3)"
            }
          ]
        end
      end
    end
  end
end
