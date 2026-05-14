# frozen_string_literal: true

require 'test_helper'

module Minitest
  module Subjective
    class FileResult
      class LineStatisticsTest < Minitest::Test
        setup do
          @branch_range_array = [1, 2, 1, 4]
          @branch_hits_array = [[:then, 1, *@branch_range_array], 1]
          @range_array = [1, 2, 3, 4]
          @conditional_hits_hash = { [:if, 1, *@range_array] => [@branch_hits_array] }
          @branch_statistics = BranchStatistics.from_hash(@conditional_hits_hash)
          @line_hits = LineStatistics::LineHits.from_pair(1, 2, branches: @branch_statistics)
          @line_statistics = LineStatistics.new([@line_hits])
          @missed_line_statistics = LineStatistics.new([LineStatistics::LineHits.from_pair(2, 0)])
        end

        test 'can be created with branches' do
          assert_equal @line_statistics, LineStatistics.from_hash([2], branches: @branch_statistics)
        end

        test 'adds lines' do
          assert_hits 4, @line_statistics + @line_statistics
          with_duped_lines_for @line_statistics do |line_statistics|
            line_statistics.lines.values.first.hits -= 1

            assert_hits 3, @line_statistics + line_statistics
          end
        end

        test 'does not add lines unless other exists' do
          assert_hits 2, @line_statistics + nil
        end

        test 'subtracts lines' do
          assert_hits 0, @line_statistics - @line_statistics
          with_duped_lines_for @line_statistics do |line_statistics|
            line_statistics.lines.values.first.hits -= 1

            assert_hits 1, @line_statistics - line_statistics
          end
        end

        test 'does not subtract lines unless other exists' do
          assert_hits 2, @line_statistics - nil
        end

        test 'returns max hits' do
          assert_equal 2, @line_statistics.max_hits
          assert_equal 0, @missed_line_statistics.max_hits
        end

        test 'returns true if covered' do
          assert_predicate @line_statistics, :covered?
          refute_predicate @missed_line_statistics, :covered?
        end

        test 'equals structurally identical lines' do
          assert_equal @line_statistics, @line_statistics.dup
          with_duped_lines_for @line_statistics do |line_statistics|
            line_statistics.lines.values.first.hits -= 1

            refute_equal @line_statistics, line_statistics
          end
        end

        private

        def assert_hits(hits, actual)
          assert_equal hits, actual.lines.values.flat_map(&:hits).sum
        end

        def with_duped_lines_for(line_statistics)
          line_statistics.dup.tap do |statistics|
            statistics.lines = statistics.lines.transform_values(&:dup)

            yield statistics
          end
        end
      end
    end
  end
end
