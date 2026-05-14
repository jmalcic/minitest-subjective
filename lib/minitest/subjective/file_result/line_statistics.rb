# frozen_string_literal: true

require 'forwardable'
require 'minitest/subjective/file_result/line_statistics/line_hits'
require 'minitest/subjective/file_result/line_statistics/formatting'

module Minitest
  module Subjective
    class FileResult
      class LineStatistics # :nodoc:
        include Formatting

        extend Forwardable

        attr_accessor :lines

        def_delegators :lines, :[], :each, :count, :compact

        def self.from_hash(lines, branches:)
          new(lines.filter_map.with_index { |value, key| value && LineHits.from_pair(key + 1, value, branches:) })
        end

        def initialize(lines = [])
          @lines = lines.to_h { [_1.line, _1] }
        end

        def +(other)
          return self unless other

          self.class.new(lines.values.zip(other.lines.values).collect { |current, new| current + new })
        end

        def -(other)
          return self unless other

          self.class.new(lines.values.zip(other.lines.values).collect { |current, new| current - new })
        end

        def max_hits
          lines.values.collect(&:hits).max
        end

        def covered?
          lines.values.all?(&:covered?)
        end

        def ==(other)
          other && lines == other.lines && branches == other.branches
        end

        protected

        attr_reader :branches
      end
    end
  end
end
