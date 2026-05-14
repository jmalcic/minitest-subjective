# frozen_string_literal: true

module Minitest
  module Subjective
    class FileResult
      class LineStatistics
        module Formatting # :nodoc:
          def format(formatter, lines)
            lines.collect.with_index do |line, line_number|
              [line_number(formatter, line_number),
               hit_count(formatter, line_number + 1),
               yield(line, line_number + 1)].join(' ')
            end
          end

          private

          def line_number(formatter, line_number)
            formatter.colors.format :gray do
              line_number.next.to_s.rjust(count.to_s.length)
            end
          end

          def hit_count(formatter, line_number)
            formatter.colors.format hits: self[line_number]&.hits do
              self[line_number]&.then { "(#{_1.hits} hit#{'s' unless _1.hits == 1})" }
                               .to_s
                               .rjust(max_hits.to_s.length + 7)
            end
          end
        end
      end
    end
  end
end
