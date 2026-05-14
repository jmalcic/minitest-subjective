# frozen_string_literal: true

require 'test_helper'

module Minitest
  module Subjective
    class FileResult
      class MethodStatistics
        class MethodHitsTest < Minitest::Test
          Dummy = Struct.new

          setup do
            @range_array = [1, 2, 3, 4]
            @branch_statistics = BranchStatistics.new([])
            @method_hits = MethodHits.new(Dummy.name, 'bar', Range.from_array(@range_array), 2, @branch_statistics)
            @missed_method_hits = MethodHits.new(Dummy.name, 'bar', Range.from_array(@range_array), 0,
                                                 @branch_statistics)
            @missed_branch_hits = BranchStatistics.from_hash([:if, 1, 1, 2, 0] => [[[:then, 1, 1, 2, 0], 0]])
            @missed_branch_method_hits = MethodHits.new(Dummy.name, 'bar', Range.from_array(@range_array), 2,
                                                        @missed_branch_hits)
          end

          test 'can be created from pair' do
            assert_equal @method_hits,
                         MethodHits.from_pair([Dummy, @method_hits.name, *@range_array], @method_hits.hits,
                                              branches: @branch_statistics)
          end

          test 'adds other hits' do
            assert_hits 4, @method_hits + @method_hits
            assert_hits 3, @method_hits + @method_hits.dup.tap { _1.hits -= 1 }
          end

          test 'does not add hits unless other exists' do
            assert_hits 2, @method_hits + nil
          end

          test 'subtracts other hits' do
            assert_hits 0, @method_hits - @method_hits
            assert_hits 1, @method_hits - @method_hits.dup.tap { _1.hits -= 1 }
          end

          test 'does not subtract hits unless other exists' do
            assert_hits 2, @method_hits - nil
          end

          test 'returns true if covered' do
            assert_predicate @method_hits, :covered?
            refute_predicate @missed_method_hits, :covered?
            refute_predicate @missed_branch_method_hits, :covered?
          end

          test 'delegates to range' do
            assert_respond_to @method_hits, :cover?
            assert_respond_to @method_hits, :starts_at?
            assert_respond_to @method_hits, :ends_at?
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
