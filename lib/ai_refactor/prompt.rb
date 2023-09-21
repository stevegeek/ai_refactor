# frozen_string_literal: true

module AIRefactor
  class Prompt
    INPUT_FILE_PATH_MARKER = "__{{input_file_path}}__"
    OUTPUT_FILE_PATH_MARKER = "__{{output_file_path}}__"
    HEADER_MARKER = "__{{prompt_header}}__"
    FOOTER_MARKER = "__{{prompt_footer}}__"
    CONTEXT_MARKER = "__{{context}}__"
    CONTENT_MARKER = "__{{content}}__"

    attr_reader :input_file_path

    def initialize(options:, logger:, context: nil, input_content: nil, input_path: nil, output_file_path: nil, prompt: nil, prompt_header: nil, prompt_footer: nil)
      @input_content = input_content
      @input_file_path = input_path
      @output_file_path = output_file_path
      @logger = logger
      @header = prompt_header
      @footer = prompt_footer
      @diff = options[:diff]
      @context = context
      @prompt = prompt || raise(StandardError, "Prompt not provided")
    end

    def chat_messages
      [
        {role: "system", content: system_prompt},
        {role: "user", content: user_prompt}
      ]
    end

    private

    def system_prompt
      prompt = expand_prompt(system_prompt_template, HEADER_MARKER, @header || "")
      prompt = expand_prompt(prompt, CONTEXT_MARKER, @context&.prepare_context || "")
      prompt = expand_prompt(prompt, INPUT_FILE_PATH_MARKER, @input_file_path || "")
      prompt = expand_prompt(prompt, OUTPUT_FILE_PATH_MARKER, @output_file_path || "")
      expand_prompt(prompt, FOOTER_MARKER, system_prompt_footer)
    end

    def system_prompt_template
      @prompt
    end

    def system_prompt_footer
      if @diff && @footer
        "#{@footer}\n\n#{diff_prompt}"
      elsif @diff
        diff_prompt
      elsif @footer
        @footer
      else
        ""
      end
    end

    def diff_prompt
      File.read(prompt_path("diff.md"))
    end

    def prompt_path(file)
      File.join(File.dirname(File.expand_path(__FILE__)), "prompts", file)
    end

    def user_prompt
      expand_prompt(input_prompt, CONTENT_MARKER, input_to_process)
    end

    def input_to_process
      return File.read(@input_file_path) if @input_file_path
      @input_content
    end

    def input_prompt
      File.read(prompt_path("input.md"))
    end

    def expand_prompt(prompt, marker, content)
      prompt.gsub(marker, content)
    end
  end
end
