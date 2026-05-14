# frozen_string_literal: true

require 'test_helper'

module Minitest
  class SubjectiveTest < Minitest::Test
    class TestFake < Test
    end

    Fake = Struct.new

    setup do
      @mock = Mock.new(Coverage)
      @load_result = { __FILE__ => { lines: [1, 2] } }
      @autoload_result = { __FILE__ => { lines: [1, 2] } }
      @baseline_result = { __FILE__ => { lines: [3, 5] } }
      @final_result = { __FILE__ => { lines: [9, 18] } }
    end

    teardown do
      Subjective.load_results = {}
      Subjective.baselines = {}
    end

    test 'has a version number' do
      refute_empty ::Minitest::Subjective::VERSION
    end

    test 'starts coverage' do
      @mock.expect :start, nil, [:all]
      @mock.expect :running?, false
      Subjective.stub :coverage, @mock do
        Subjective.start_coverage
      end

      assert_mock @mock
    end

    test 'does not start coverage if running' do
      @mock.expect :running?, true
      Subjective.stub :coverage, @mock do
        Subjective.start_coverage
      end

      assert_mock @mock
    end

    test 'records load' do
      @mock.expect :peek_result, @load_result
      Subjective.stub :coverage, @mock do
        Subjective.record_load_for Fake
      end

      assert_mock @mock
      assert_equal Subjective::FileResult.from_result(__FILE__, @autoload_result[__FILE__]),
                   Subjective.load_results[Fake.name]
    end

    test 'records autoload' do
      @mock.expect :peek_result, @autoload_result
      Subjective.stub :coverage, @mock do
        Subjective.record_autoload_for Fake.name, __FILE__
      end

      assert_mock @mock
      assert_equal Subjective::FileResult.from_result(__FILE__, @autoload_result[__FILE__]),
                   Subjective.load_results[Fake.name]
    end

    test 'records baselines' do
      @mock.expect :peek_result, @baseline_result
      Subjective.stub :coverage, @mock do
        Subjective.record_baseline_for TestFake
      end

      assert_mock @mock
      assert Subjective.baselines.key?(Fake.name)
      assert_equal Subjective::FileResult.from_result(__FILE__, @baseline_result[__FILE__]),
                   Subjective.baselines[Fake.name]
    end

    test 'returns coverage for a subject' do
      @mock.expect :running?, true
      @mock.expect :peek_result, @final_result

      Subjective.stub :coverage, @mock do
        assert_equal Subjective::FileResult.from_result(__FILE__, @final_result[__FILE__]),
                     Subjective.coverage_for(Fake)
      end
    end

    test 'returns nil when coverage is not running' do
      @mock.expect :running?, false

      Subjective.stub :coverage, @mock do
        assert_nil Subjective.coverage_for(Fake)
      end
    end

    test 'subtracts baseline from coverage' do
      @mock.expect :peek_result, @baseline_result
      @mock.expect :running?, true
      @mock.expect :peek_result, @final_result
      Subjective.stub :coverage, @mock do
        Subjective.record_baseline_for TestFake

        assert_equal Subjective::FileResult.from_result(__FILE__, lines: [6, 13]),
                     Subjective.coverage_for(Fake)
      end
    end
  end
end
