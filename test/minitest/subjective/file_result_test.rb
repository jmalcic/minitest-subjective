# frozen_string_literal: true

require 'test_helper'

module Minitest
  module Subjective
    class FileResultTest < Minitest::Test
      Dummy = Struct.new

      setup do
        @path = 'test/minitest/subjective/file_result_test.rb'
        @modes = { branches: { [:if, 1, 1, 2, 3, 4] => { [:then, 1, 1, 2, 1, 4] => 1 } }, lines: [1],
                   methods: { [Dummy, :bar, 1, 2, 3, 4] => 2 } }
        @range_array = [1, 2, 3, 4]
        @branch_statistics = FileResult::BranchStatistics.from_hash({ [:if, 1, *@range_array] =>
                                                                        [[[:then, 1, 1, 2, 1, 4], 1]] })
        @line_statistics = FileResult::LineStatistics.from_hash([1], branches: @branch_statistics)
        @missed_line_statistics = FileResult::LineStatistics.from_hash([nil, 0], branches: nil)
        @method_statistics = FileResult::MethodStatistics.from_hash({ [Dummy, :bar, *@range_array] => 2 },
                                                                    branches: @branch_statistics)
        @file_result = FileResult.new(@path, line_statistics: @line_statistics, method_statistics: @method_statistics)
        @missed_file_result = FileResult.new(@path, line_statistics: @missed_line_statistics)
      end

      test 'can be created with branches' do
        assert_equal @file_result, FileResult.from_result(@path, @modes)
      end

      test 'adds file results' do
        assert_hits 2, @file_result + @file_result
        assert_hits 1, @file_result + nil
        assert_hits 1, @file_result + @missed_file_result
      end

      test 'subtracts file results' do
        assert_hits 0, @file_result - @file_result
        assert_hits 1, @file_result - nil
        assert_hits 1, @file_result - @missed_file_result
      end

      test 'returns true if blank' do
        assert_predicate FileResult.new(@path, line_statistics: nil), :blank?
        refute_predicate @file_result, :blank?
      end

      test 'can be converted to string' do
        refute_empty @file_result.to_s
      end

      test 'returns true if covered' do
        assert_predicate @file_result, :covered?
        refute_predicate @missed_file_result, :covered?
      end

      test 'equals structurally identical file results' do
        assert_equal @file_result, @file_result.dup
      end

      private

      def assert_hits(hits, actual)
        assert_equal hits, actual.line_statistics.lines.values.flat_map(&:hits).sum
      end
    end
  end
end
