# frozen_string_literal: true

require 'test_helper'

require 'minitest/subjective/file_result/branch_statistics/branch_hits'
require 'minitest/subjective/file_result/branch_statistics/conditional_hits'

module Minitest
  module Subjective
    class FileResult
      class BranchStatisticsTest < Minitest::Test
        setup do
          @branch_range_array = [1, 2, 1, 4]
          @branch_hits_array = [[:then, 1, *@branch_range_array], 2]
          @missed_branch_hits_array = [[:else, 2, *@branch_range_array], 0]
          @range_array = [1, 2, 3, 4]
          @conditional_hits_array = [:if, 1, *@range_array]
          @conditional_hits = BranchStatistics::ConditionalHits.from_pair(@conditional_hits_array, [@branch_hits_array])
          @missed_conditional_hits = BranchStatistics::ConditionalHits.from_pair(@conditional_hits_array,
                                                                                 [@branch_hits_array,
                                                                                  @missed_branch_hits_array])
          @branch_statistics = BranchStatistics.new([@conditional_hits])
          @missed_branch_statistics = BranchStatistics.new([@conditional_hits, @missed_conditional_hits])
        end

        test 'can be created with branches' do
          assert_equal @branch_statistics,
                       BranchStatistics.from_hash({ @conditional_hits_array => [@branch_hits_array] })
        end

        test 'adds branches' do
          assert_hits 4, @branch_statistics + @branch_statistics
          with_duped_branches_for @branch_statistics do |branch_statistics|
            branch_statistics.branches.first.branches.first.hits -= 1

            assert_hits 3, @branch_statistics + branch_statistics
          end
        end

        test 'does not add branches unless other exists' do
          assert_hits 2, @branch_statistics + nil
        end

        test 'subtracts branches' do
          assert_hits 0, @branch_statistics - @branch_statistics
          with_duped_branches_for @branch_statistics do |branch_statistics|
            branch_statistics.branches.first.branches.first.hits -= 1

            assert_hits 1, @branch_statistics - branch_statistics
          end
        end

        test 'does not subtract branches unless other exists' do
          assert_hits 2, @branch_statistics - nil
        end

        test 'indexes branches' do
          assert_equal [@conditional_hits], @branch_statistics[1]
          assert_empty @branch_statistics[8]
        end

        test 'filters branches' do
          assert_equal @branch_statistics, @branch_statistics.filter(&:covered?)
          assert_empty @branch_statistics.filter { _1.label == :else }
                                         .branches
        end

        test 'returns true if covered' do
          assert_predicate @branch_statistics, :covered?
          refute_predicate @missed_branch_statistics, :covered?
        end

        test 'equals structurally identical branches' do
          assert_equal @branch_statistics, @branch_statistics.dup
          with_duped_branches_for @branch_statistics do |branch_statistics|
            branch_statistics.branches.first.branches.first.hits -= 1

            refute_equal @branch_statistics, branch_statistics
          end
        end

        private

        def assert_hits(hits, actual)
          assert_equal hits, actual.branches.flat_map(&:branches).sum(&:hits)
        end

        def with_duped_branches_for(branch_statistics)
          branch_statistics.dup.tap do |statistics|
            statistics.branches = statistics.branches.collect(&:dup)
            statistics.branches.each { _1.branches = _1.branches.collect(&:dup) }
            yield statistics
          end
        end
      end
    end
  end
end
