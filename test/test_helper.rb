# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'minitest/subjective'
require 'minitest/mock'
require 'minitest/autorun'

module Minitest
  class Test
    def self.test(name, &block)
      "test_#{name.gsub(/\s+/, '_')}".then do |test_name|
        raise "#{test_name} is already defined." if method_defined?(test_name)

        define_method(test_name, &block || -> { flunk "No implementation provided for #{name}." })
      end
    end

    def self.setup(&)
      define_method(:setup, &)
    end

    def self.teardown(&)
      define_method(:teardown, &)
    end
  end
end
