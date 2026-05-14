# frozen_string_literal: true

module Minitest
  module Subjective
    module TestExtensions # :nodoc:
      def self.prepend_target
        Test.prepend self
      end

      def run(*)
        Subjective.record_load_for(self.class)
        Subjective.record_baseline_for(self.class)
        super
      end
    end
  end
end
