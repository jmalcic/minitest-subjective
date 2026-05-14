# frozen_string_literal: true

require 'test_helper'

module Minitest
  module Subjective
    class FileResult
      class BranchStatistics
        class FormattingTest < Minitest::Test
          class Formatter
            class Colors
              def format(color = nil, hits: false)
                "<#{tag_for(hits, color)}>#{yield}</#{tag_for(hits, color, close: true)}>"
              end

              private

              def tag_for(hits, color, close: false)
                hits == false ? (color || :none) : ['hits', *("count=\"#{hits}\"" unless close)].join(' ')
              end
            end

            def colors
              @colors ||= Colors.new
            end
          end

          setup do
            @formatter = Formatter.new
            @conditional_hits = ConditionalHits.new(:if, 1,
                                                    Range.from_array([1, 0, 1, 2]),
                                                    [BranchHits.from_pair([:then, 1, 1, 0, 1, 1], 2),
                                                     BranchHits.from_pair([:else, 2, 1, 1, 1, 2], 1)])
          end

          test 'returns nil when there are no conditionals covering the line' do
            @conditional_hits = ConditionalHits.new(:if, 1, Range.from_array([2, 0, 2, 2]), [])

            assert_nil format_statistics('ab', 1)
          end

          test 'formats conditionals and branches at their start/end positions' do
            assert_formatted <<~XML.chomp, 'ab', 1
              <root><gray>[</gray><gray>if</gray> <gray>[</gray>a <hits count="2"><framed>then (2 hits)</framed></hits><gray>]</gray><gray>[</gray>b <hits count="1"><framed>else (1 hit)</framed></hits><gray>]</gray><gray>]</gray></root>
            XML
          end

          private

          def assert_formatted(exp, line, hits)
            assert_equal(exp, format_statistics(line, hits).then { "<root>#{_1}</root>" })
          end

          def format_statistics(line, hits)
            BranchStatistics.new([@conditional_hits]).format(@formatter, line, hits)
          end
        end
      end
    end
  end
end
