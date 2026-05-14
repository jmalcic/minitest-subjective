# frozen_string_literal: true

require 'forwardable'
require 'minitest/subjective/file_result/range'
require 'minitest/subjective/file_result/branch_statistics/formatting'
require 'minitest/subjective/file_result/branch_statistics/branch_hits'
require 'minitest/subjective/file_result/branch_statistics/conditional_hits'

module Minitest
  module Subjective
    class FileResult
      class BranchStatistics # :nodoc:
        include Formatting

        attr_accessor :branches

        def self.from_hash(branches)
          new(branches.collect { |key, value| ConditionalHits.from_pair(key, value) })
        end

        def initialize(branches)
          @branches = branches
        end

        def +(other)
          return self unless other

          self.class.new(branches.zip(other.branches).collect { |current, new| current + new })
        end

        def -(other)
          return self unless other

          self.class.new(branches.zip(other.branches).collect { |current, new| current - new })
        end

        def [](index)
          branches.filter { _1.cover?(index) }
        end

        def filter(&)
          self.class.new(branches.filter(&))
        end

        def covered?
          branches.all?(&:covered?)
        end

        def ==(other)
          other && branches == other.branches
        end
      end
    end
  end
end
