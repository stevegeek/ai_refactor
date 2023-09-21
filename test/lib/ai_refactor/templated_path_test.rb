require "minitest/autorun"
require "minitest/mock"
require_relative "../../../lib/ai_refactor/templated_path"

module AIRefactor
  class TemplatedPathTest < Minitest::Test
    def setup
      @input_file = "dir/file.ext"
      @refactor_name = "refactor"
      @template = "path/to/[DIR]/[FILE]/[REFACTOR]"
      @templated_path = AIRefactor::TemplatedPath.new(@input_file, @refactor_name, @template)
    end

    def test_initialize_raises_error_when_template_length_is_not_positive
      assert_raises ArgumentError do
        AIRefactor::TemplatedPath.new(@input_file, @refactor_name, "")
      end
    end

    def test_generate_returns_path_from_template
      expected_result = "path/to/dir/file.ext/refactor"
      assert_equal expected_result, @templated_path.generate
    end

    def test_path_from_template_with_substitution
      @template = "path/to/[DIR|r|-r]/[FILE|.ext|.txt]/[REFACTOR]"
      @templated_path = AIRefactor::TemplatedPath.new(@input_file, @refactor_name, @template)
      expected_result = "path/to/di-r/file.txt/refactor"
      assert_equal expected_result, @templated_path.generate
    end

    def test_path_from_template_with_substitution_with_slash
      @template = "path/to/[DIR|dir|app/new]-[NAME]"
      @templated_path = AIRefactor::TemplatedPath.new(@input_file, @refactor_name, @template)
      expected_result = "path/to/app/new-file"
      assert_equal expected_result, @templated_path.generate
    end
  end
end
