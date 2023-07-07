# frozen_string_literal: true

module AIRefactor
  class Prompt
    attr_reader :file_path, :prompt_file_path

    def initialize(input_path:, prompt_file_path:, diff: false)
      @file_path = input_path
      @prompt_file_path = prompt_file_path
      @diff = diff
    end

    def chat_prompt
      [
        {role: "system", content: system_prompt},
        {role: "user", content: user_prompt}
      ]
    end

    private

    def prompt_path(file)
      File.join(File.dirname(File.expand_path(__FILE__)), "prompts", file)
    end

    def system_prompt
      File.read(@prompt_file_path)
    end

    def user_prompt
      input = File.read(@file_path)
      input_prompt_expanded = expand_prompt(input_prompt, input)
      @diff ? "#{diff_prompt}\n#{input_prompt_expanded}" : input_prompt_expanded
    end

    def input_prompt
      File.read(prompt_path("input.md"))
    end

    def diff_prompt
      File.read(prompt_path("diff.md"))
    end

    def expand_prompt(prompt, content)
      prompt.gsub("__{{content}}__", content)
    end
  end
end
