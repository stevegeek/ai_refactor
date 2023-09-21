module AIRefactor
  class TemplatedPath
    def initialize(input_file, refactor_name, template)
      @input_file = input_file
      @refactor_name = refactor_name
      raise ArgumentError unless template.length.positive?
      @template = template
    end

    def generate
      path_from_template
    end

    private

    def path_from_template
      path = @template.dup
      @template.scan(/\[(FILE|NAME|DIR|REFACTOR|EXT)(\|([^|]+)\|([^\]]*))?\]/).each do |match|
        type, sub, old_value, new_value = match
        puts "type: #{type}, sub: #{sub}, old_value: #{old_value}, new_value: #{new_value}"
        value = send(type.downcase.to_sym)
        value = value.gsub(old_value, new_value) if sub
        path.gsub!("[#{type}#{sub}]", value)
      end
      path
    end

    def file
      File.basename(@input_file)
    end

    def name
      File.basename(@input_file, ".*")
    end

    def dir
      File.dirname(@input_file)
    end

    def refactor
      @refactor_name
    end

    def ext
      File.extname(@input_file)
    end
  end
end
