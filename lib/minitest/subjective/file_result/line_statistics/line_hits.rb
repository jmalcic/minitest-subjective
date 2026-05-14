# frozen_string_literal: true

module Minitest
  module Subjective
    class FileResult
      class LineStatistics
        LineHits = Struct.new(:line, :hits, :branches) do
          def self.from_pair(line, hits, branches: nil)
            new(line:, hits:, branches:)
          end

          def +(other)
            return self unless other && other.line == line

            self.class.new(line, hits + other.hits, branches && (branches + other.branches))
          end

          def -(other)
            return self unless other && other.line == line

            self.class.new(line, hits - other.hits, branches && (branches - other.branches))
          end

          def covered?
            hits.positive? && (branches.nil? || branches.covered?)
          end
        end
      end
    end
  end
end
