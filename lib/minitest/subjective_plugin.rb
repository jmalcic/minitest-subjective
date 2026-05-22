# frozen_string_literal: true

module Minitest # :nodoc:
  class << self
    private

    def add_zeitwerk_hooks
      return unless defined? ::Zeitwerk

      ::Zeitwerk::Registry.loaders.each do |loader|
        loader.on_load do |cpath, _value, abspath|
          Subjective.record_autoload_for(cpath, abspath)
        end
      end
    end
  end

  def self.plugin_subjective_options(opts, options)
    opts.on '--subjective', 'Collect focused coverage for the test subjects.' do
      options[:subjective] ||= {}
    end
  end

  def self.plugin_subjective_init(options)
    return unless options[:subjective] || ENV['MINITEST_SUBJECTIVE']

    require 'minitest/subjective'

    add_zeitwerk_hooks
    Subjective.start_coverage
    Subjective::ResultExtensions.prepend_target
    Subjective::TestExtensions.prepend_target
    reporter << Subjective::Reporter.new
  end
end
