# frozen_string_literal: true

require 'test_helper'

module Minitest
  module Subjective
    class CaseInquirerTest < Minitest::Test
      Fake = Struct.new

      module ::ActiveSupport
        class TestCase < Minitest::Test
        end
      end

      module ::ActionDispatch
        class IntegrationTest < ActiveSupport::TestCase
        end
      end

      class TestFake < Minitest::Test
      end

      class FakeActiveSupportTest < ::ActiveSupport::TestCase
      end

      class FakeActionDispatchTest < ::ActionDispatch::IntegrationTest
      end

      setup do
        @case_inquirer = CaseInquirer.new(TestFake)
      end

      test 'can be initialized with class name' do
        assert_equal @case_inquirer, CaseInquirer.new('Minitest::Subjective::CaseInquirerTest::TestFake')
      end

      test 'returns class name' do
        assert_equal 'Minitest::Subjective::CaseInquirerTest::TestFake', @case_inquirer.class_name
      end

      test 'returns subject file' do
        assert_equal __FILE__, @case_inquirer.subject_file
      end

      test 'returns subject name' do
        assert_equal 'Minitest::Subjective::CaseInquirerTest::Fake', @case_inquirer.subject_name
        assert_equal 'Minitest::Subjective::CaseInquirerTest::FakeActiveSupport',
                     CaseInquirer.new('Minitest::Subjective::CaseInquirerTest::FakeActiveSupportTest').subject_name
        assert_equal 'Minitest::Subjective::CaseInquirerTest::Fake',
                     CaseInquirer.new('Minitest::Subjective::CaseInquirerTest::Fake').subject_name
      end

      test 'returns true if a test' do
        assert_predicate @case_inquirer, :test?
        refute_predicate CaseInquirer.new(Fake), :test?
        assert_predicate CaseInquirer.new(FakeActiveSupportTest), :test?
      end

      test 'returns true if a Rails test' do
        assert_predicate CaseInquirer.new(FakeActiveSupportTest), :rails_test?
        refute_predicate @case_inquirer, :rails_test?
      end

      test 'returns true if an integration test' do
        assert_predicate CaseInquirer.new(FakeActionDispatchTest), :integration_test?
        refute_predicate CaseInquirer.new(FakeActiveSupportTest), :integration_test?
        refute_predicate @case_inquirer, :integration_test?
      end

      test 'equal to structurally identical case inquirer' do
        assert_equal @case_inquirer, @case_inquirer.dup
        refute_equal @case_inquirer, CaseInquirer.new('Minitest::Subjective::CaseInquirerTest::Fake')
      end
    end
  end
end
