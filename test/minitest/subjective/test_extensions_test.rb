# frozen_string_literal: true

require 'test_helper'

module Minitest
  module Subjective
    class TestExtensionsTest < Minitest::Test
      class FakeTestCase < Minitest::Test
        prepend TestExtensions
      end

      setup do
        @mock = Minitest::Mock.new
        @fake_test = FakeTestCase.new 'fake'
      end

      teardown do
        Subjective.baselines.clear
        Subjective.load_results.clear
      end

      test 'records load for test case' do
        assert_empty Subjective.baselines
        @mock.expect :peek_result, { __FILE__ => { lines: [1] } }
        @mock.expect :peek_result, { __FILE__ => { lines: [1] } }
        with_stub do
          @fake_test.run
        end

        assert_mock @mock
        refute_empty Subjective.baselines
      end

      test 'records baseline for test case' do
        assert_empty Subjective.baselines
        @mock.expect :peek_result, { __FILE__ => { lines: [1] } }
        @mock.expect :peek_result, { __FILE__ => { lines: [1] } }
        with_stub do
          @fake_test.run
        end

        assert_mock @mock
        refute_empty Subjective.load_results
      end

      private

      def with_stub(&)
        Subjective.stub(:coverage, @mock, &)
      end
    end
  end
end
