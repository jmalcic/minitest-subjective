# frozen_string_literal: true

require 'forwardable'
require 'minitest/subjective/file_result/method_statistics/method_hits'
require 'minitest/subjective/file_result/range'
require 'minitest/subjective/file_result/method_statistics/formatting'

module Minitest
  module Subjective
    class FileResult
      class MethodStatistics # :nodoc:
        include Formatting

        attr_reader :method_hits

        def self.from_hash(methods, branches:)
          new(methods.collect { |key, value| MethodHits.from_pair(key, value, branches:) })
        end

        def initialize(methods)
          @method_hits = methods
        end

        def +(other)
          return self unless other

          self.class.new(method_hits.zip(other.method_hits).collect { |current, new| current + new })
        end

        def -(other)
          return self unless other

          self.class.new(method_hits.zip(other.method_hits).collect { |current, new| current - new })
        end

        def find_by(**options)
          method_hits.find { |method| options.all? { |key, value| method.send(key) == value } }
        end

        def max_hits
          method_hits.collect(&:hits).max
        end

        def [](index)
          method_hits.find { _1.cover?(index) } if index
        end

        def find_by_index(index)
          method_hits.find { _1.starts_at?(index) } if index
        end

        def covered?
          method_hits.all?(&:covered?)
        end

        def ==(other)
          other && method_hits == other.method_hits && branches == other.branches
        end

        protected

        attr_reader :branches
      end
    end
  end
end
