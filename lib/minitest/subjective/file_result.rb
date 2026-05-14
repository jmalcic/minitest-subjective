# frozen_string_literal: true

require 'minitest/subjective/file_result/branch_statistics'
require 'minitest/subjective/file_result/line_statistics'
require 'minitest/subjective/file_result/method_statistics'
require 'minitest/subjective/formatter'

module Minitest
  module Subjective
    class FileResult # :nodoc:
      attr_reader :path, :line_statistics, :method_statistics

      def self.from_result(path, modes)
        BranchStatistics.from_hash(modes[:branches].to_h).then do |branches|
          new(path, line_statistics: LineStatistics.from_hash(modes[:lines].to_a, branches:),
                    method_statistics: MethodStatistics.from_hash(modes[:methods].to_h, branches:))
        end
      end

      def initialize(path, line_statistics:, method_statistics: nil)
        @path = path
        @line_statistics = line_statistics
        @method_statistics = method_statistics
      end

      def +(other)
        return self unless other

        self.class.new(@path, line_statistics: other ? line_statistics + other.line_statistics : line_statistics,
                              method_statistics:
                                other ? method_statistics + other.method_statistics : method_statistics)
      end

      def -(other)
        return self unless other

        self.class.new(@path, line_statistics: other ? line_statistics - other.line_statistics : line_statistics,
                              method_statistics:
                                other ? method_statistics - other.method_statistics : method_statistics)
      end

      def blank?
        line_statistics.nil?
      end

      def to_s = Formatter.new(self).render

      def covered?
        line_statistics.covered? && method_statistics.covered?
      end

      def ==(other)
        other && line_statistics == other.line_statistics && method_statistics == other.method_statistics
      end
    end
  end
end
