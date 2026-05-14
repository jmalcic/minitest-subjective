# frozen_string_literal: true

module Minitest
  module Subjective
    class FileResult
      class BranchStatistics
        module Formatting # :nodoc:
          def format(formatter, line, line_number)
            return unless conditionals_for_line(line_number).any?

            line.each_char
                .flat_map
                .with_index { |character, column| format_character(formatter, character, line_number, column) }
                .join
          end

          private

          def format_character(formatter, character, line_number, column)
            [*format_conditionals_starting_at_position(formatter, line_number, column),
             *format_branches_starting_at_position(formatter, line_number, column),
             character,
             *format_branches_ending_at_position(formatter, line_number, column),
             *format_conditionals_ending_at_position(formatter, line_number, column)]
          end

          def format_conditionals_starting_at_position(formatter, line_number, column)
            conditionals_starting_at_position(line_number, column).collect do |conditional|
              [formatter.colors.format(:gray) { '[' },
               formatter.colors.format(:gray) { conditional.label },
               ' '].join
            end
          end

          def format_branches_starting_at_position(formatter, line_number, column)
            branches_starting_at_position(line_number, column).collect { formatter.colors.format(:gray) { '[' } }
          end

          def format_conditionals_ending_at_position(formatter, line_number, column)
            conditionals_ending_at_position(line_number, column + 1).collect { formatter.colors.format(:gray) { ']' } }
          end

          def format_branches_ending_at_position(formatter, line_number, column)
            branches_ending_at_position(line_number, column + 1).collect do |branch|
              [' ', framed_hits(formatter, branch), formatter.colors.format(:gray) { ']' }].join
            end
          end

          def framed_hits(formatter, branch)
            formatter.colors.format(hits: branch.hits) do
              formatter.colors.format(:framed) do
                "#{branch.label} #{hit_count(branch)}"
              end
            end
          end

          def conditionals_for_line(line_number)
            @branches.filter { _1.cover?(line_number) }
          end

          def conditionals_starting_at_position(line_number, column)
            @branches.filter { _1.starts_at?(line_number, column) }
          end

          def conditionals_ending_at_position(line_number, column)
            @branches.filter { _1.ends_at?(line_number, column) }
          end

          def branches_starting_at_position(line_number, column)
            @branches.flat_map(&:branches).filter { _1.starts_at?(line_number, column) }
          end

          def branches_ending_at_position(line_number, column)
            @branches.flat_map(&:branches).filter { _1.ends_at?(line_number, column) }
          end

          def hit_count(branch)
            "(#{branch.hits} hit#{'s' unless branch.hits == 1})"
          end
        end
      end
    end
  end
end
