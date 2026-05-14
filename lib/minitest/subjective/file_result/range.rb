# frozen_string_literal: true

require 'minitest/subjective/file_result/location'

module Minitest
  module Subjective
    class FileResult
      Range = Struct.new(:start, :end) do
        def self.from_array(args)
          new(start: Location.from_array(args[0..1]), end: Location.from_array(args[2..3]))
        end

        def starts_at?(line, column = nil)
          column ? start == Location.new(line, column) : start.line == line
        end

        def ends_at?(line, column = nil)
          column ? self.end == Location.new(line, column) : self.end.line == line
        end

        def cover?(line_or_range, column_or_start_column = nil, end_column = nil)
          (covers_line?(line_or_range) && !column_or_start_column) || covers_column?(line_or_range,
                                                                                     column_or_start_column, end_column)
        end

        def to_s
          if single_line?
            [start.line, [start.column, self.end.column].join('-')].join(':')
          else
            [start.to_s, self.end.to_s].join('-')
          end
        end

        private

        def covers_column?(line_or_range, column_or_start_column, _end_column = nil)
          return single_line_covers_column?(column_or_start_column) if single_line?

          multiple_lines_covers_column?(line_or_range, column_or_start_column, nil)
        end

        def single_line_covers_column?(column)
          (start.column..self.end.column).cover?(column)
        end

        def multiple_lines_covers_column?(line_or_range, column_or_start_column, end_column = nil)
          case line_or_range
          when start.line then (start.column..).cover?(column_or_start_column)
          when start.line.next...self.end.line then true
          when self.end.line then (1..self.end.column).cover?(end_column)
          else false
          end
        end

        def covers_line?(line_or_range)
          case line_or_range
          when Range then (start.line..self.end.line).cover?(line_or_range.start.line..line_or_range.end.line)
          else (start.line..self.end.line).cover?(line_or_range)
          end
        end

        def single_line?
          start.line == self.end.line
        end
      end
    end
  end
end
