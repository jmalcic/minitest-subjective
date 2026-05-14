# frozen_string_literal: true

module Minitest
  module Subjective
    class FileResult
      class BranchStatistics
        BranchHits = Struct.new(:label, :id, :range, :hits) do
          extend Forwardable

          def_delegators :range, :starts_at?, :ends_at?, :cover?

          def self.from_pair(key, hits)
            label, id, *range = key
            new(label:, id:, range: Range.from_array(range), hits:)
          end

          def +(other)
            return self unless matches?(other)

            self.class.new(label, id, range, hits + other.hits)
          end

          def -(other)
            return self unless matches?(other)

            self.class.new(label, id, range, hits - other.hits)
          end

          def covered?
            hits.positive?
          end

          private

          def matches?(other)
            other && other.label == label && other.id == id && other.range == range
          end
        end
      end
    end
  end
end
