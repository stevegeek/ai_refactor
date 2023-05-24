# frozen_string_literal: true

require_relative "ai_refactor/version"

require_relative "ai_refactor/logger"
require_relative "ai_refactor/file_processor"

require_relative "ai_refactor/refactors"
require_relative "ai_refactor/base_refactor"
require_relative "ai_refactor/refactors/generic"
require_relative "ai_refactor/refactors/rspec_to_minitest_rails"
require_relative "ai_refactor/refactors/minitest_to_rspec"
