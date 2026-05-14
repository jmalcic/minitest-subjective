# frozen_string_literal: true

module Minitest
  module Subjective
    class FileResult
      class MethodStatistics
        module Formatting # :nodoc:
          def format(formatter, line, line_number, &)
            [hit_count(formatter, line_number), branches_or_line(line, line_number, &)].join(' ')
          end

          private

          def branches_or_line(line, line_number, &)
            self[line_number]&.then { _1.branches.branches.any? ? yield(_1.branches) : line } || line
          end

          def hit_count(formatter, line_number)
            formatter.colors.format hits: find_by_index(line_number)&.hits do
              find_by_index(line_number)&.then { "(#{_1.hits} hit#{'s' unless _1.hits == 1})" }
                                        .to_s
                                        .rjust(max_hits.to_s.length + 7)
            end
          end
        end
      end
    end
  end
end
