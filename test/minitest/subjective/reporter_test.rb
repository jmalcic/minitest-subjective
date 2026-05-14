# frozen_string_literal: true

require 'test_helper'

module Minitest
  module Subjective
    class ReporterTest < Minitest::Test
      setup do
        @io = StringIO.new
        @reporter = Subjective::Reporter.new(@io, {})
        @test_case = TestFake
      end

      teardown do
        Subjective.load_results = {}
      end

      FakeResult = Struct.new(:klass, :coverage_result, :load_result)

      Dummy = Struct.new

      Fake = Struct.new

      class TestFake < Test
      end

      class TestMissing < Test
      end

      test 'records coverage when subject file exists' do
        @reporter.results[inquirer.subject_name] = file_result_from(hits: 10)

        @reporter.record(FakeResult.new(TestFake, file_result_from(hits: 3)))

        assert_hits 13, @reporter.results[inquirer.subject_name]
      end

      test 'does nothing when subject file is nil' do
        @test_case = TestMissing

        assert_nil inquirer.subject_file

        @reporter.results[inquirer.subject_name] = file_result_from('does_not_matter.rb', hits: 10)
        @reporter.record(FakeResult.new(TestMissing, file_result_from('does_not_matter.rb', hits: 3)))

        assert_hits 10, @reporter.results[inquirer.subject_name]
      end

      test 'seeds from eager load_result when missing in results' do
        Subjective.load_results[inquirer.subject_name] = file_result_from(hits: 100)

        @reporter.record(FakeResult.new(TestFake, file_result_from(hits: 7)))

        assert_hits 107, @reporter.results[inquirer.subject_name]
      end

      test 'stores coverage_result when results were empty' do
        @reporter.record(FakeResult.new(TestFake, file_result_from(hits: 107)))

        assert_hits 107, @reporter.results[inquirer.subject_name]
      end

      test 'accumulates coverage_result onto an existing results entry' do
        @reporter.results[inquirer.subject_name] = file_result_from(hits: 1)

        @reporter.record(FakeResult.new(TestFake, file_result_from(hits: 7)))

        assert_hits 8, @reporter.results[inquirer.subject_name]
      end

      test 'reports coverage' do
        assert_empty @io.string
        @reporter.results[inquirer.subject_name] = file_result_from(hits: 1)
        @reporter.record(FakeResult.new(TestFake, file_result_from(hits: 7)))
        @reporter.report

        assert_match 'Coverage for Minitest::Subjective::ReporterTest::Fake:', @io.string
      end

      private

      def inquirer
        Subjective::CaseInquirer.new(@test_case)
      end

      def file_result_from(path = inquirer.subject_file, hits:)
        Subjective::FileResult.from_result(path,
                                           branches: {},
                                           lines: [hits],
                                           methods: { [Dummy, :bar, 1, 2, 3, 4] => hits })
      end

      def assert_hits(hits, actual)
        assert_equal hits, actual.line_statistics.lines.values.flat_map(&:hits).sum
      end
    end
  end
end
