# frozen_string_literal: true

require 'test_helper'

module Minitest
  module Subjective
    class FileResult
      class LineStatistics
        class LineHitsTest < Minitest::Test
          setup do
            @line_hits = LineHits.new(1, 2, nil)
            @missed_line_hits = LineHits.new(2, 0, nil)
            @missed_branch_hits = BranchStatistics.from_hash([:if, 1, 1, 2, 0] => [[[:then, 1, 1, 2, 0], 0]])
            @missed_branch_line_hits = LineHits.new(2, 1, @missed_branch_hits)
          end

          test 'can be created with line and hit count' do
            assert_equal @line_hits, LineHits.from_pair(@line_hits.line, @line_hits.hits)
          end

          test 'can be created with line, hit count and branches' do
            assert_equal @missed_branch_line_hits,
                         LineHits.from_pair(@missed_branch_line_hits.line, @missed_branch_line_hits.hits,
                                            branches: @missed_branch_hits)
          end

          test 'adds hits' do
            assert_hits 4, @line_hits + @line_hits
            assert_hits 3, @line_hits + @line_hits.dup.tap { _1.hits -= 1 }
          end

          test 'does not add hits unless other exists' do
            assert_hits 2, @line_hits + nil
          end

          test 'does not add hits unless matching line' do
            assert_hits 2, @line_hits + @line_hits.dup.tap { _1.line += 1 }
          end

          test 'subtracts hits' do
            assert_hits 0, @line_hits - @line_hits
            assert_hits 1, @line_hits - @line_hits.dup.tap { _1.hits -= 1 }
          end

          test 'does not subtract hits unless other exists' do
            assert_hits 2, @line_hits - nil
          end

          test 'does not subtract hits unless matching line' do
            assert_hits 2, @line_hits - @line_hits.dup.tap { _1.line += 1 }
          end

          test 'returns true if covered' do
            assert_predicate @line_hits, :covered?
            refute_predicate @missed_line_hits, :covered?
            refute_predicate @missed_branch_line_hits, :covered?
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
