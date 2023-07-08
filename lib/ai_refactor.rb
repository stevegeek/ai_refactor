# frozen_string_literal: true

require "zeitwerk"
loader = Zeitwerk::Loader.for_gem
loader.inflector.inflect(
  "ai_refactor" => "AIRefactor",
  "rspec_runner" => "RSpecRunner"
)
loader.setup # ready!

module AIRefactor
  class NoOutputError < StandardError; end
  # Your code goes here...
end

# We eager load here to ensure that all Refactor classes are loaded at startup so they can be registered
loader.eager_load
