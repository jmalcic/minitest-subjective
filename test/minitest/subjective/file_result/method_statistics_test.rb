# frozen_string_literal: true

require 'test_helper'

module Minitest
  module Subjective
    class FileResult
      class MethodStatisticsTest < Minitest::Test
        Dummy = Struct.new

        setup do
          @branch_hits_array = [[:then, 1, 1, 2, 1, 4], 1]
          @range_array = [1, 2, 3, 4]
          @conditional_hits_hash = { [:if, 1, *@range_array] => [@branch_hits_array] }
          @branch_statistics = BranchStatistics.from_hash(@conditional_hits_hash)
          @method_hits = MethodStatistics::MethodHits.from_pair([Dummy, 'bar', *@range_array], 2,
                                                                branches: @branch_statistics)
          @missed_method_hits = MethodStatistics::MethodHits.from_pair([Dummy, 'bar', *@range_array], 0,
                                                                       branches: @branch_statistics)
          @method_statistics = MethodStatistics.new([@method_hits])
          @missed_method_statistics = MethodStatistics.new([@missed_method_hits])
        end

        test 'can be created with branches' do
          assert_equal @method_statistics, MethodStatistics.from_hash({ [Dummy, 'bar', *@range_array] => 2 },
                                                                      branches: @branch_statistics)
        end

        test 'adds methods' do
          assert_hits 4, @method_statistics + @method_statistics
          assert_hits 2, @method_statistics + nil
          assert_hits 2, @method_statistics + @missed_method_statistics
        end

        test 'subtracts methods' do
          assert_hits 0, @method_statistics - @method_statistics
          assert_hits 2, @method_statistics - nil
          assert_hits 2, @method_statistics - @missed_method_statistics
        end

        test 'finds by options' do
          assert_equal @method_hits, @method_statistics.find_by(klass: Dummy.name)
        end

        test 'returns max hits' do
          assert_equal 2, @method_statistics.max_hits
          assert_equal 0, @missed_method_statistics.max_hits
        end

        test 'indexes methods' do
          assert_equal @method_hits, @method_statistics[1]
          assert_nil @method_statistics[8]
        end

        test 'finds by index' do
          assert_equal @method_hits, @method_statistics.find_by_index(1)
          assert_nil @method_statistics.find_by_index(8)
        end

        test 'returns true if covered' do
          assert_predicate @method_statistics, :covered?
          refute_predicate @missed_method_statistics, :covered?
        end

        test 'equals structurally identical methods' do
          assert_equal @method_statistics, @method_statistics.dup
        end

        private

        def assert_hits(hits, actual)
          assert_equal hits, actual.method_hits.flat_map(&:hits).sum
        end
      end
    end
  end
end
