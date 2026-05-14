# frozen_string_literal: true

require 'test_helper'

require 'tempfile'

module Minitest
  module Subjective
    class FormatterTest < Minitest::Test
      test 'initialize exposes a colors helper' do
        with_formatter_from("x\n") do |formatter|
          assert_kind_of Formatter::Colors, formatter.colors
        end
      end

      test 'render reads the subject file and joins formatted lines' do
        with_formatter_from("plain\n") do |formatter|
          assert_equal '1  (1 hit)         plain', strip_escapes(formatter.render)
        end
      end

      test 'render formats each physical line including line numbers' do
        with_formatter_from("first\nsecond\n", line_statistics: [1, 1]) do |formatter|
          assert_equal "1  (1 hit)         first\n2  (1 hit)         second", strip_escapes(formatter.render)
        end
      end

      test 'render inlines branch decorations when method branch data exists' do
        with_formatter_from("abcd\n",
                            line_statistics: [1],
                            method_statistics: { [Object, :new, 1, 1, 1, 4] => 3 },
                            branch_statistics: { [:if, 1, 1, 1, 1, 4] => [[[:then, 1, 1, 1, 1, 4], 2]] }) do |formatter|
          strip_escapes(formatter.render).then do |stripped|
            assert_includes stripped, 'then (2 hits)'
            assert_includes stripped, 'if'
            assert_match(/a.*b.*c.*d/, stripped)
          end
        end
      end

      private

      def strip_escapes(string)
        string.gsub(/\e\[[0-9;]*m/, '')
      end

      def branch_statistics_from(args)
        FileResult::BranchStatistics.from_hash(args) if args
      end

      def line_statistics_from(hash = nil, branches: nil, **options)
        FileResult::LineStatistics.from_hash(hash || [1], branches: branch_statistics_from(branches), **options)
      end

      def method_statistics_from(hash = nil, branches: nil, **options)
        FileResult::MethodStatistics.from_hash(hash.to_h, branches: branch_statistics_from(branches), **options)
      end

      def file_result_from(path, line_statistics = nil, method_statistics = nil, branch_statistics = nil)
        FileResult.new(path,
                       line_statistics: line_statistics_from(line_statistics, branches: branch_statistics),
                       method_statistics: method_statistics_from(method_statistics, branches: branch_statistics))
      end

      def with_formatter_from(source, line_statistics: nil, method_statistics: nil, branch_statistics: nil)
        Tempfile.create(%w[formatter .rb]) do |temp|
          temp.write(source)
          temp.flush
          yield Formatter.new(file_result_from(temp.path, line_statistics, method_statistics, branch_statistics))
        end
      end
    end
  end
end
