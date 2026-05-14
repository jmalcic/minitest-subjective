# frozen_string_literal: true

module Minitest
  module Subjective
    class FileResult
      class BranchStatistics
        ConditionalHits = Struct.new(:label, :id, :range, :branches) do
          extend Forwardable

          def_delegators :range, :starts_at?, :ends_at?, :cover?

          def self.from_pair(key, branches)
            label, id, *range = key
            new(label:, id:, range: Range.from_array(range), branches: branches.collect { BranchHits.from_pair(*_1) })
          end

          def +(other)
            return self unless matches?(other)

            self.class.new(label, id, range, branches.zip(other.branches).collect { |current, new| current + new })
          end

          def -(other)
            return self unless matches?(other)

            self.class.new(label, id, range, branches.zip(other.branches).collect { |current, new| current - new })
          end

          def covered?
            branches.all?(&:covered?)
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
