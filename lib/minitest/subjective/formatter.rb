# frozen_string_literal: true

require 'minitest/subjective/formatter/colors'

module Minitest
  module Subjective
    class Formatter # :nodoc:
      attr_reader :colors

      def initialize(result)
        @result = result
        @colors = Colors.new
      end

      def render
        formatted_lines.join("\n")
      end

      private

      attr_reader :result

      def lines = File.readlines(result.path, chomp: true)

      def formatted_lines
        result.line_statistics.format(self, lines) do |line, number|
          result.method_statistics.format(self, line, number) do |branch_statistics|
            branch_statistics.format(self, line, number)
          end
        end
      end
    end
  end
end
