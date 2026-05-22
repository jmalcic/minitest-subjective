# frozen_string_literal: true

module Minitest
  module Subjective
    class CaseInquirer # :nodoc:
      attr_reader :class_name, :subject_file

      def initialize(klass)
        @class_name = klass.is_a?(String) ? klass : klass.name
        @klass = klass.is_a?(String) ? safe_constantize(klass) : klass
        load_subject
        @subject_file = Object.const_source_location(subject_name)&.first
      end

      def subject_name
        return class_name unless test?
        return [*class_name_nesting, demodulized_class_name.delete_suffix('Test')].join('::') if rails_test?

        [*class_name_nesting, demodulized_class_name.delete_prefix('Test')].join('::')
      end

      def test? = rails_test? || minitest_test?

      def minitest_test?
        demodulized_class_name.start_with?('Test') && klass < Minitest::Test
      end

      def rails_test?
        demodulized_class_name.end_with?('Test') && klass < Minitest::Test
      end

      def integration_test? = rails_test? && defined?(::ActionDispatch) && klass < ActionDispatch::IntegrationTest
      def ==(other) = class_name == other.class_name && klass == other.klass && subject_file == other.subject_file

      protected

      attr_reader :klass

      private

      def load_subject = safe_constantize(subject_name)

      def class_name_nesting
        class_name.split('::')[0..-2].join('::').then { |nesting| nesting unless nesting.empty? }
      end

      def demodulized_class_name
        class_name.split('::').last
      end

      def safe_constantize(name)
        Object.const_get(name)
      rescue NameError
        nil
      end
    end
  end
end
