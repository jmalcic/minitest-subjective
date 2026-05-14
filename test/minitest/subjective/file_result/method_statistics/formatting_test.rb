# frozen_string_literal: true

require 'test_helper'

module Minitest
  module Subjective
    class FileResult
      class MethodStatistics
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

          Dummy = Struct.new

          setup do
            @formatter = Formatter.new
          end

          test 'formats hit count and line when method has no branches' do
            @method_hits = [MethodHits.from_pair([Dummy, 'bar', 1, 2, 3, 4], 2, branches: BranchStatistics.new([]))]

            assert_formatted <<~XML.chomp, 'puts :hi', 1
              <method><hits count="2">(2 hits)</hits> puts :hi</method>
            XML
            assert_formatted <<~XML.chomp, 'puts :bye', 2
              <method><hits count="">        </hits> puts :bye</method>
            XML
          end

          test 'hit count is padded to the width of max_hits and pluralizes hits' do
            @method_hits = [MethodHits.from_pair([Dummy, 'one', 1, 0, 1, 0], 1, branches: BranchStatistics.new([])),
                            MethodHits.from_pair([Dummy, 'twelve', 2, 0, 2, 0], 12,
                                                 branches: BranchStatistics.new([]))]

            assert_formatted <<~XML.chomp, 'x', 1
              <method><hits count="1">  (1 hit)</hits> x</method>
            XML
            assert_formatted <<~XML.chomp, 'y', 2
              <method><hits count="12">(12 hits)</hits> y</method>
            XML
            assert_formatted <<~XML.chomp, 'z', 3
              <method><hits count="">         </hits> z</method>
            XML
          end

          test 'yields branches when method has any branches' do
            @method_hits = [MethodHits.from_pair([Dummy, 'bar', 1, 2, 3, 4], 1,
                                                 branches: BranchStatistics.from_hash([:if, 1, 1, 2, 3, 4] =>
                                                                                        [[[:then, 1, 1, 2, 3, 4], 1]]))]

            assert_formatted <<~XML.chomp, 'original', 1, branch_statistics_formatter
              <method><hits count="1"> (1 hit)</hits> <branches>or<gray>[</gray><gray>if</gray> <gray>[</gray>iginal</branches></method>
            XML
          end

          private

          def assert_formatted(exp, line, line_number, proc = nil)
            assert_equal(exp, format(line, line_number, &proc).then { "<method>#{_1}</method>" })
          end

          def format(line, line_number, &)
            MethodStatistics.new(@method_hits).format(@formatter, line, line_number, &)
          end

          def branch_statistics_formatter
            ->(branch_statistics) { "<branches>#{branch_statistics.format(@formatter, 'original', 1)}</branches>" }
          end
        end
      end
    end
  end
end
