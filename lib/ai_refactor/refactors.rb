# frozen_string_literal: true

module AIRefactor
  module Refactors
    def get(name)
      all[name]
    end
    module_function :get

    def names
      all.keys
    end
    module_function :names

    def all
      @all ||= constants.map { |n| const_get(n) }.select { |c| c.is_a? Class }.each_with_object({}) do |klass, hash|
        hash[klass.refactor_name] = klass
      end
    end
    module_function :all

    def supported?(name)
      names.include?(name)
    end
    module_function :supported?
  end
end
