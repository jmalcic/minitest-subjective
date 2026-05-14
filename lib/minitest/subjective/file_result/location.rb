# frozen_string_literal: true

module Minitest
  module Subjective
    class FileResult
      Location = Struct.new(:line, :column) do
        def self.from_array(args)
          new(line: args[0], column: args[1])
        end

        def to_s
          [line, column].join(':')
        end
      end
    end
  end
end
