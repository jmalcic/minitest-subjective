# frozen_string_literal: true

require 'test_helper'

module Minitest
  module Subjective
    class FileResult
      class BranchStatistics
        class BranchHitsTest < Minitest::Test
          setup do
            @range_array = [1, 2, 3, 4]
            @branch_hits = BranchHits.new(:if, 1, Range.from_array(@range_array), 2)
            @missed_branch_hits = BranchHits.new(:if, 2, Range.from_array(@range_array), 0)
          end

          test 'can be created from pair' do
            assert_equal @branch_hits,
                         BranchHits.from_pair([@branch_hits.label, @branch_hits.id, *@range_array], @branch_hits.hits)
          end

          test 'adds hits' do
            assert_hits 4, @branch_hits + @branch_hits
            assert_hits 3, @branch_hits + @branch_hits.dup.tap { _1.hits -= 1 }
          end

          test 'does not add hits unless other exists' do
            assert_hits 2, @branch_hits + nil
          end

          test 'does not add hits unless matching label' do
            assert_hits 2, @branch_hits + @branch_hits.dup.tap { _1.label = :else }
          end

          test 'does not add hits unless matching id' do
            assert_hits 2, @branch_hits + @branch_hits.dup.tap { _1.id += 1 }
          end

          test 'does not add hits unless matching range' do
            assert_hits 2, @branch_hits + @branch_hits.dup.tap { _1.range = Range.from_array(@range_array.reverse) }
          end

          test 'subtracts hits' do
            assert_hits 0, @branch_hits - @branch_hits
            assert_hits 1, @branch_hits - @branch_hits.dup.tap { _1.hits -= 1 }
          end

          test 'does not subtract hits unless other exists' do
            assert_hits 2, @branch_hits - nil
          end

          test 'does not subtract hits unless matching label' do
            assert_hits 2, @branch_hits - @branch_hits.dup.tap { _1.label = :else }
          end

          test 'does not subtract hits unless matching id' do
            assert_hits 2, @branch_hits - @branch_hits.dup.tap { _1.id += 1 }
          end

          test 'does not subtract hits unless matching range' do
            assert_hits 2, @branch_hits - @branch_hits.dup.tap { _1.range = Range.from_array(@range_array.reverse) }
          end

          test 'returns true if covered' do
            assert_predicate @branch_hits, :covered?
            refute_predicate @missed_branch_hits, :covered?
          end

          test 'delegates to range' do
            assert_respond_to @branch_hits, :starts_at?
            assert_respond_to @branch_hits, :ends_at?
            assert_respond_to @branch_hits, :cover?
          end

          private

          def assert_hits(hits, actual)
            assert_equal hits, actual.hits
          end
        end
      end
    end
  end
end
