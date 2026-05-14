# frozen_string_literal: true

module Minitest
  module Subjective
    class FileResult
      class MethodStatistics
        MethodHits = Struct.new(:klass, :name, :range, :hits, :branches) do
          extend Forwardable

          def_delegators :range, :cover?, :starts_at?, :ends_at?

          def self.from_pair(key, hits, branches: [])
            klass, name, *range = key
            range = Range.from_array(range)
            new(klass: klass.name, name:, range:, hits:, branches: branches.filter { range.cover?(_1.range) })
          end

          def +(other)
            return self unless other

            self.class.new(klass, name, range, hits + other.hits, branches && (branches + other.branches))
          end

          def -(other)
            return self unless other

            self.class.new(klass, name, range, hits - other.hits, branches && (branches - other.branches))
          end

          def covered?
            hits.positive? && (branches.nil? || branches.covered?)
          end
        end
      end
    end
  end
end
