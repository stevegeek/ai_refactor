# frozen_string_literal: true

require_relative "ai_refactor/version"

require_relative "ai_refactor/logger"
require_relative "ai_refactor/prompt"
require_relative "ai_refactor/context"
require_relative "ai_refactor/file_processor"

require_relative "ai_refactor/test_runners/test_run_result"
require_relative "ai_refactor/test_runners/rspec_runner"
require_relative "ai_refactor/test_runners/minitest_runner"
require_relative "ai_refactor/test_runners/test_run_diff_report"

require_relative "ai_refactor/refactors"
require_relative "ai_refactor/refactors/base_refactor"
require_relative "ai_refactor/refactors/generic"
require_relative "ai_refactor/refactors/rails/minitest/rspec_to_minitest"
# require_relative "ai_refactor/refactors/minitest_to_rspec"
