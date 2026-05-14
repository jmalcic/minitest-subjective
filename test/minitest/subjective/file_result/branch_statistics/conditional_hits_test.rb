# frozen_string_literal: true

require 'test_helper'

module Minitest
  module Subjective
    class FileResult
      class BranchStatistics
        class ConditionalHitsTest < Minitest::Test
          setup do
            @branch_range_array = [1, 2, 1, 4]
            @branch_hits = BranchHits.from_pair([:then, 1, *@branch_range_array], 2)
            @missed_branch_hits = BranchHits.from_pair([:else, 2, *@branch_range_array], 0)
            @range_array = [1, 2, 3, 4]
            @conditional_hits = ConditionalHits.new(:if, 1, Range.from_array(@range_array), [@branch_hits])
            @missed_conditional_hits = ConditionalHits.new(:if, 1, Range.from_array(@range_array),
                                                           [@missed_branch_hits, @branch_hits])
          end

          test 'can be created from pair' do
            assert_equal @conditional_hits,
                         ConditionalHits.from_pair([@conditional_hits.label, @conditional_hits.id, *@range_array],
                                                   [[[@branch_hits.label, @branch_hits.id, *@branch_range_array],
                                                     @branch_hits.hits]])
          end

          test 'adds hits' do
            assert_hits 4, @conditional_hits + @conditional_hits
            with_duped_branches_for @conditional_hits do |conditional_hits|
              conditional_hits.branches.first.hits -= 1

              assert_hits 3, @conditional_hits + conditional_hits
            end
          end

          test 'does not add hits unless other exists' do
            assert_hits 2, @conditional_hits + nil
          end

          test 'does not add hits unless matching label' do
            assert_hits 2, @conditional_hits + @conditional_hits.dup.tap { _1.label = :else }
          end

          test 'does not add hits unless matching id' do
            assert_hits 2, @conditional_hits + @conditional_hits.dup.tap { _1.id += 1 }
          end

          test 'does not add hits unless matching range' do
            with_duped_branches_for @conditional_hits do |conditional_hits|
              conditional_hits.range = Range.from_array(@range_array.reverse)

              assert_hits 2, @conditional_hits + conditional_hits
            end
          end

          test 'subtracts hits' do
            assert_hits 0, @conditional_hits - @conditional_hits
            with_duped_branches_for @conditional_hits do |conditional_hits|
              conditional_hits.branches.first.hits -= 1

              assert_hits 1, @conditional_hits - conditional_hits
            end
          end

          test 'does not subtract hits unless other exists' do
            assert_hits 2, @conditional_hits - nil
          end

          test 'does not subtract hits unless matching label' do
            assert_hits 2, @conditional_hits - @conditional_hits.dup.tap { _1.label = :else }
          end

          test 'does not subtract hits unless matching id' do
            assert_hits 2, @conditional_hits - @conditional_hits.dup.tap { _1.id += 1 }
          end

          test 'does not subtract hits unless matching range' do
            assert_hits 2,
                        @conditional_hits - @conditional_hits.dup
                                                             .tap { _1.range = Range.from_array(@range_array.reverse) }
          end

          test 'returns true if covered' do
            assert_predicate @conditional_hits, :covered?
            refute_predicate @missed_conditional_hits, :covered?
          end

          test 'delegates to range' do
            assert_respond_to @conditional_hits, :starts_at?
            assert_respond_to @conditional_hits, :ends_at?
            assert_respond_to @conditional_hits, :cover?
          end

          private

          def assert_hits(hits, actual)
            assert_equal hits, actual.branches.sum(&:hits)
          end

          def with_duped_branches_for(hits)
            yield hits.dup.tap { _1.branches = _1.branches.collect(&:dup) }
          end
        end
      end
    end
  end
end
