# frozen_string_literal: true

module AIRefactor
  module Refactors
    def register(klass)
      all[klass.refactor_name] = klass
    end
    module_function :register

    def get(name)
      all[name]
    end
    module_function :get

    def names
      all.keys
    end
    module_function :names

    def descriptions
      names.map { |n| "\"#{n}\"" }.zip(all.values.map(&:description)).to_h
    end
    module_function :descriptions

    def supported?(name)
      names.include?(name)
    end
    module_function :supported?

    def all
      @all ||= {}
    end
    module_function :all
  end
end
