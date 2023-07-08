# frozen_string_literal: true

require "minitest/autorun"
require "minitest/mock"
require_relative "../../../lib/ai_refactor/context"

module AIRefactor
  class ContextTest < Minitest::Test
    def setup
      @logger = Minitest::Mock.new
      @context = Context.new(files: ["file1", "file2"], logger: @logger)
    end

    def test_prepare_context_with_existing_files
      File.stub :exist?, true do
        File.stub :read, "content" do
          expected_output = "Extra context from the codebase: #---\n# file1\n\ncontent\n#---\n# file2\n\ncontent"
          assert_equal expected_output, @context.prepare_context
        end
      end
    end

    def test_prepare_context_with_non_existing_files
      File.stub :exist?, false do
        @logger.expect :warn, nil, ["Context file file1 does not exist"]
        @logger.expect :warn, nil, ["Context file file2 does not exist"]
        assert_equal "", @context.prepare_context
        @logger.verify
      end
    end

    def test_prepare_context_with_mixed_files
      File.stub :exist?, lambda { |file| file == "file1" } do
        File.stub :read, "content" do
          @logger.expect :warn, nil, ["Context file file2 does not exist"]
          expected_output = "Extra context from the codebase: #---\n# file1\n\ncontent"
          assert_equal expected_output, @context.prepare_context
          @logger.verify
        end
      end
    end
  end
end
