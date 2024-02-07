# frozen_string_literal: true

module AIRefactor
  module Commands
    # TODO: support command_line_options
    BuiltInCommand = Data.define(:name, :description, :path, :command_line_options, :config)

    def get(name)
      all[name]
    end
    module_function :get

    def names
      all.keys
    end
    module_function :names

    def descriptions
      names.map { |n| "\"#{n}\"" }.zip(all.values.map(&:description)).to_h
    end
    module_function :descriptions

    def supported?(name)
      names.include?(name)
    end
    module_function :supported?

    def all
      @all ||= begin
        commands = Dir.glob(File.join(__dir__, "../../commands", "**/*.yml")).map do |path|
          path_to_commands = File.join(__dir__, "../../commands/")
          name = File.join(File.dirname(path.gsub(path_to_commands, "")), File.basename(path, ".yml")).to_sym
          config = YAML.safe_load_file(path, permitted_classes: [Symbol], symbolize_names: true, aliases: true)
          BuiltInCommand.new(name: name, path: path, description: config[:description], config: config, command_line_options: [])
        end
        commands.map { |c| [c.name, c] }.to_h
      end
    end
    module_function :all
  end
end
