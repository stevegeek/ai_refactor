# frozen_string_literal: true

require_relative "lib/ai_refactor/version"

Gem::Specification.new do |spec|
  spec.name = "ai_refactor"
  spec.version = AIRefactor::VERSION
  spec.authors = ["Stephen Ierodiaconou"]
  spec.email = ["stevegeek@gmail.com"]

  spec.summary = "Use AI to convert a Rails RSpec test suite to minitest."
  spec.description = "Use OpenAI's ChatGPT to automate converting Rails RSpec tests to minitest (ActiveSupport::TestCase)."
  spec.homepage = "https://github.com/stevegeek/ai_refactor"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.3.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/stevegeek/ai_refactor"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) || f.start_with?(*%w[bin/ test/ spec/ features/ examples/ .github/ .git .circleci appveyor])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "colorize", "< 2.0"
  spec.add_dependency "open3", "< 2.0"
  spec.add_dependency "ruby-openai", ">= 3.4.0", "< 6.0"
  spec.add_dependency "anthropic", ">= 0.1.0", "< 1.0"
  spec.add_dependency "zeitwerk", "~> 2.6"
  spec.add_dependency "bundler", "> 1.3"
end
