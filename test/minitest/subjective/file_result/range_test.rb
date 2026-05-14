# frozen_string_literal: true

require 'test_helper'

module Minitest
  module Subjective
    class FileResult
      class RangeTest < Minitest::Test
        setup do
          @range = Range.new(Location.new(1, 2), Location.new(3, 4))
          @single_line_range = Range.new(Location.new(1, 2), Location.new(1, 4))
        end

        test 'can be created with start and end arguments' do
          assert_equal @range, Range.new(@range.start, @range.end)
        end

        test 'can be created with start and end options' do
          assert_equal @range, Range.new(start: @range.start, end: @range.end)
        end

        test 'can be created from array' do
          assert_equal @range,
                       Range.from_array([@range.start.line, @range.start.column, @range.end.line, @range.end.column])
        end

        test 'returns true if starts at line' do
          assert @range.starts_at?(@range.start.line)
          refute @range.starts_at?(@range.start.line.next)
        end

        test 'returns true if starts at line and column' do
          assert @range.starts_at?(@range.start.line, @range.start.column)
          refute @range.starts_at?(@range.start.line, @range.start.column.next)
        end

        test 'returns true if ends at line' do
          assert @range.ends_at?(@range.end.line)
          refute @range.ends_at?(@range.end.line.next)
        end

        test 'returns true if ends at line and column' do
          assert @range.ends_at?(@range.end.line, @range.end.column)
          refute @range.ends_at?(@range.end.line, @range.end.column.next)
        end

        test 'returns true if covers line' do
          assert @range.cover?(@range.start.line)
          assert @range.cover?(@range.end.line)
        end

        test 'returns false if does not cover line' do
          refute @range.cover?(@range.start.line.pred)
          refute @range.cover?(@range.end.line.next)
        end

        test 'returns true if covers range' do
          assert @range.cover?(@range)
          assert @range.cover?(Range.new(Location.new(@range.start.line.next, @range.start.column.next),
                                         Location.new(@range.end.line.pred, @range.end.column.pred)))
        end

        test 'returns false if does not cover range' do
          refute @range.cover?(Range.new(Location.new(@range.start.line.pred, @range.start.column.pred),
                                         Location.new(@range.end.line.next, @range.end.column.next)))
        end

        test 'returns true if covers line and column' do
          assert @range.cover?(@range.start.line, @range.start.column, @range.end.column)
          assert @range.cover?(@range.start.line.next, @range.start.column, @range.end.column)
        end

        test 'returns false if does not cover line and column' do
          refute @range.cover?(@range.start.line, @range.start.column.pred, @range.end.column)
          refute @range.cover?(@range.end.line, @range.start.column, @range.end.column.next)
          refute @range.cover?(@range.end.line.next, @range.start.column, @range.end.column)
        end

        test 'can be converted to string for multiple lines' do
          assert_equal '1:2-3:4', @range.to_s
        end

        test 'can be converted to string for single line' do
          assert_equal '1:2-4', @single_line_range.to_s
        end
      end
    end
  end
end
