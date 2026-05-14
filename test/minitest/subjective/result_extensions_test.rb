# frozen_string_literal: true

require 'test_helper'

module Minitest
  module Subjective
    class ResultExtensionsTest < Minitest::Test
      class FakeResult < Minitest::Result
        prepend ResultExtensions

        def self.runnable_methods
          []
        end
      end

      class FakeTestCase < Minitest::Test
      end

      setup do
        @mock = Minitest::Mock.new
      end

      test 'records coverage result' do
        @mock.expect :running?, true
        @mock.expect :peek_result, { __FILE__ => { lines: [1] } }

        with_stub do
          assert_kind_of FileResult, FakeResult.from(FakeTestCase.new('name')).coverage_result
        end

        assert_mock @mock
      end

      private

      def with_stub(&)
        Subjective.stub(:coverage, @mock, &)
      end
    end
  end
end
