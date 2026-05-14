# frozen_string_literal: true

require 'test_helper'

module Minitest
  module Subjective
    class FileResult
      class LineStatistics
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
            @line_hits = [LineHits.from_pair(1, 2)]
          end

          test 'format returns an array of formatted lines' do
            assert_formatted <<~XML.chomp, ["puts 'hi'", 'exit 0']
              <line><gray>1</gray> <hits count="2">(2 hits)</hits> <line-content number="1">puts 'hi'</line-content></line>
              <line><gray>2</gray> <hits count="">        </hits> <line-content number="2">exit 0</line-content></line>
            XML
          end

          test 'line number is padded to the width of count' do
            @line_hits = (2..121).map { LineHits.from_pair(_1, 0) }

            assert_formatted <<~XML.chomp, %w[x]
              <line><gray>  1</gray> <hits count="">        </hits> <line-content number="1">x</line-content></line>
            XML
          end

          test 'hit count is padded to the width of max_hits and pluralizes hits' do
            @line_hits = LineHits.from_pair(1, 1), LineHits.from_pair(2, 2), LineHits.from_pair(3, 12)

            assert_formatted <<~XML.chomp, %w[a b c]
              <line><gray>1</gray> <hits count="1">  (1 hit)</hits> <line-content number="1">a</line-content></line>
              <line><gray>2</gray> <hits count="2"> (2 hits)</hits> <line-content number="2">b</line-content></line>
              <line><gray>3</gray> <hits count="12">(12 hits)</hits> <line-content number="3">c</line-content></line>
            XML
          end

          private

          def assert_formatted(exp, line)
            assert_equal exp,
                         format(line).collect { "<line>#{_1}</line>" }
                                     .join("\n")
          end

          def format(line)
            LineStatistics.new(@line_hits).format(@formatter, line) do |line_content, line_number|
              "<line-content number=\"#{line_number}\">#{line_content}</line-content>"
            end
          end
        end
      end
    end
  end
end
