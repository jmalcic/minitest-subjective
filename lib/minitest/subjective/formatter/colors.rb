# frozen_string_literal: true

module Minitest
  module Subjective
    class Formatter
      class Colors # :nodoc:
        CSI = "\033["
        FINAL_BYTE = 'm'
        CODES = {
          clear: 0,
          gray: 90,
          white: 37,
          green: 32,
          red: 31,
          underline: 4,
          strikethrough: 9,
          framed: 51,
          encircled: 52
        }.freeze
        SEPARATOR = ';'

        def initialize
          @stack = []
        end

        def format(color = nil, hits: false)
          [public_send(color_for_hits(hits) || color || :transparent), yield, clear].join
        end

        def color_for_hits(count)
          unstash

          case count
          when nil then :gray
          when 0 then :red
          when (1..) then :green
          end
        end

        def gray = push :gray
        def green = push :green
        def red = push :red
        def framed = push :framed
        def encircled = push :encircled
        def white = push :white
        def transparent = push :clear

        def clear = pop && (current || sequence(:clear))
        def clear_all = stash && sequence(:clear)

        private

        def current = @stack.last
        def push(key) = @stack.push(sequence(key)) && current
        def pop = @stack.pop
        def stash = @stash = @stack.dup.tap { @stack.clear }
        def sequence(*keys) = [CSI, CODES.values_at(*keys).join(SEPARATOR), FINAL_BYTE].join
        def unstash = @stash&.any? && @stack = @stash.dup.tap { @stash.clear }
      end
    end
  end
end
