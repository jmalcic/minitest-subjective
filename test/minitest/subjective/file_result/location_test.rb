# frozen_string_literal: true

require 'test_helper'

module Minitest
  module Subjective
    class FileResult
      class LocationTest < Minitest::Test
        setup do
          @location = FileResult::Location.new(2, 3)
        end

        test 'can be created with line and column arguments' do
          assert_equal @location, FileResult::Location.new(@location.line, @location.column)
        end

        test 'can be created with line and column options' do
          assert_equal @location, FileResult::Location.new(line: @location.line, column: @location.column)
        end

        test 'can be created from array' do
          assert_equal @location, FileResult::Location.from_array([@location.line, @location.column])
        end

        test 'can be converted to string' do
          assert_equal '2:3', @location.to_s
        end
      end
    end
  end
end
