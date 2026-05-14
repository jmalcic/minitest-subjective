# frozen_string_literal: true

module Minitest
  module Subjective
    module ResultExtensions # :nodoc: all
      module ClassMethods
        def from(runnable)
          super.tap do |output|
            output.load_result = Subjective.load_result_for(runnable.class)
            output.coverage_result = Subjective.coverage_for(runnable.class)
          end
        end
      end

      attr_accessor :load_result, :coverage_result

      def self.prepended(other)
        other.singleton_class.prepend ClassMethods
      end

      def self.prepend_target
        Result.prepend self
      end
    end
  end
end
