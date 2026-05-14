# frozen_string_literal: true

require 'test_helper'

module Minitest
  module Subjective
    class Formatter
      class ColorsTest < Minitest::Test
        setup do
          @colors = Colors.new
        end

        test 'gray returns gray SGR sequence' do
          assert_equal sequence(:gray), @colors.gray
        end

        test 'green returns green SGR sequence' do
          assert_equal sequence(:green), @colors.green
        end

        test 'red returns red SGR sequence' do
          assert_equal sequence(:red), @colors.red
        end

        test 'white returns white SGR sequence' do
          assert_equal sequence(:white), @colors.white
        end

        test 'framed returns framed SGR sequence' do
          assert_equal sequence(:framed), @colors.framed
        end

        test 'encircled returns encircled SGR sequence' do
          assert_equal sequence(:encircled), @colors.encircled
        end

        test 'transparent returns clear SGR sequence' do
          assert_equal sequence(:clear), @colors.transparent
        end

        test 'format wraps block with explicit color and final clear' do
          assert_equal "#{sequence(:red)}x#{sequence(:clear)}", @colors.format(:red) { 'x' }
        end

        test 'format without color uses transparent then clear' do
          assert_equal("#{sequence(:clear)}hi#{sequence(:clear)}", @colors.format { 'hi' })
        end

        test 'format with hits nil uses gray' do
          assert_equal "#{sequence(:gray)}x#{sequence(:clear)}", @colors.format(hits: nil) { 'x' }
        end

        test 'format with hits zero uses red' do
          assert_equal "#{sequence(:red)}x#{sequence(:clear)}", @colors.format(hits: 0) { 'x' }
        end

        test 'format with positive hits uses green' do
          assert_equal "#{sequence(:green)}x#{sequence(:clear)}", @colors.format(hits: 1) { 'x' }
          assert_equal "#{sequence(:green)}x#{sequence(:clear)}", @colors.format(hits: 42) { 'x' }
        end

        test 'format prefers hits over explicit color when both apply' do
          assert_equal "#{sequence(:green)}x#{sequence(:clear)}", @colors.format(:red, hits: 2) { 'x' }
        end

        test 'format uses explicit color when hits keyword is false' do
          assert_equal "#{sequence(:framed)}x#{sequence(:clear)}", @colors.format(:framed, hits: false) { 'x' }
        end

        test 'nested format restores outer color after inner segment' do
          assert_equal "#{sequence(:green)}#{sequence(:framed)}inner#{sequence(:green)}#{sequence(:clear)}",
                       @colors.format(:green) { @colors.format(:framed) { 'inner' } }
        end

        test 'clear pops one level and returns previous style or global clear' do
          @colors.gray
          @colors.red

          assert_equal sequence(:gray), @colors.clear
          assert_equal sequence(:clear), @colors.clear
        end

        test 'clear_all emits reset then color_for_hits restores stashed stack' do
          @colors.gray
          @colors.red

          assert_equal sequence(:clear), @colors.clear_all

          @colors.color_for_hits(1)

          assert_equal sequence(:gray), @colors.clear
          assert_equal sequence(:clear), @colors.clear
        end

        test 'color_for_hits returns gray red or green for nil zero and positive counts' do
          table = { nil => :gray, 0 => :red, 1 => :green, 100 => :green }

          assert_equal(table.values, table.keys.map { @colors.color_for_hits(_1) })
        end

        test 'color_for_hits returns nil for other counts' do
          assert_nil @colors.color_for_hits(false)
          assert_nil @colors.color_for_hits(-1)
        end

        private

        def sequence(*keys)
          [Colors::CSI,
           keys.collect { Colors::CODES.fetch(_1) }
               .join(Colors::SEPARATOR),
           Colors::FINAL_BYTE]
            .join
        end
      end
    end
  end
end
