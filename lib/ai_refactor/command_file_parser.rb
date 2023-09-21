# frozen_string_literal: true

require "yaml"

module AIRefactor
  class CommandFileParser
    def self.command_file?(name)
      name.match?(/\.ya?ml$/)
    end

    def initialize(path)
      @path = path
    end

    def parse
      raise StandardError, "Invalid command file:  file does not exist" unless File.exist?(@path)

      options = YAML.safe_load_file(@path, permitted_classes: [Symbol], symbolize_names: true, aliases: true)

      unless options && options[:refactor]
        raise StandardError, "Invalid command file format, a 'refactor' key is required"
      end

      options
    end
  end
end
