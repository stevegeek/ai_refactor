# frozen_string_literal: true

module AIRefactor
  class RunConfiguration
    def self.add_new_option(key)
      self.class.define_method(key) { instance_variable_get("@#{key}") }
      self.class.define_method("#{key}=") { |v| instance_variable_set("@#{key}", v) }
    end

    attr_reader :refactor,
      :input_file_paths,
      :output_file_path,
      :output_template_path,
      :context_file_paths,
      :context_text,
      :review_prompt,
      :prompt,
      :prompt_file_path,
      :ai_max_attempts,
      :ai_model,
      :ai_temperature,
      :ai_max_tokens,
      :ai_timeout,
      :overwrite,
      :diff,
      :verbose,
      :debug

    def set!(hash)
      hash.each do |key, value|
        raise StandardError, "Invalid option: #{key}" unless respond_to?("#{key}=")
        send("#{key}=", value)
      end
    end

    attr_writer :refactor

    # @deprecated
    def [](key)
      send(key)
    end

    def input_file_paths=(paths)
      @input_file_paths ||= []
      paths = [paths] unless paths.is_a?(Array)
      @input_file_paths.concat(paths)
    end

    attr_writer :output_file_path

    attr_writer :output_template_path

    def context_file_paths=(paths)
      @context_file_paths ||= []
      paths = [paths] unless paths.is_a?(Array)
      @context_file_paths.concat(paths)
    end

    def context_text=(text)
      @context_text ||= ""
      @context_text += text
    end

    attr_writer :review_prompt
    attr_writer :prompt
    attr_writer :prompt_file_path

    def rspec_run_command
      @rspec_run_command || "bundle exec rspec __FILE__"
    end

    def minitest_run_command
      @minitest_run_command || "ruby __FILE__"
    end

    attr_writer :rspec_run_command
    attr_writer :minitest_run_command

    def ai_max_attempts=(value)
      @ai_max_attempts = value || 3
    end

    def ai_model=(value)
      @ai_model = value || "gpt-4"
    end

    def ai_temperature=(value)
      @ai_temperature = value || 0.7
    end

    def ai_max_tokens=(value)
      @ai_max_tokens = value || 1500
    end

    def ai_timeout=(value)
      @ai_timeout = value || 60
    end

    def overwrite=(value)
      @overwrite = value || "a"
    end

    attr_writer :diff

    attr_writer :verbose

    attr_writer :debug

    def to_options
      instance_variables.each_with_object({}) do |var, hash|
        hash[var.to_s.delete("@").to_sym] = instance_variable_get(var)
      end
    end
  end
end
