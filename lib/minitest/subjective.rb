# frozen_string_literal: true

require_relative 'subjective/version'
require 'coverage'
require 'forwardable'
require 'minitest'
require 'minitest/subjective/file_result'
require 'minitest/subjective_plugin'

module Minitest # :nodoc:
  # = \Subjective
  module Subjective
    class << self
      private

      def coverage
        Coverage
      end

      def file_result_for(path)
        FileResult.from_result(path, coverage.peek_result[path].to_h)
      end
    end

    def self.cattr_accessor(name) # :nodoc:
      (class << self; self; end).attr_accessor name
    end

    cattr_accessor :load_results
    cattr_accessor :baselines
    @load_results = {}
    @baselines = {}

    def self.start_coverage
      coverage.start(:all) unless coverage.running?
    end

    def self.record_autoload_for(klass, path = nil)
      load_results[klass] ||= file_result_for(path)
    end

    def self.record_load_for(klass, _path = nil)
      CaseInquirer.new(klass).tap do |inquirer|
        load_results[inquirer.subject_name] ||= file_result_for(inquirer.subject_file)
      end
    end

    def self.record_baseline_for(klass)
      CaseInquirer.new(klass).tap do |inquirer|
        baselines[inquirer.subject_name] = file_result_for(inquirer.subject_file)
      end
    end

    def self.load_result_for(klass)
      CaseInquirer.new(klass).then do |inquirer|
        load_results[inquirer.subject_name]
      end
    end

    def self.coverage_for(klass)
      CaseInquirer.new(klass).then do |inquirer|
        next unless coverage.running?

        file_result_for(inquirer.subject_file) - baselines[inquirer.subject_name]
      end
    end
  end

  load :subjective if respond_to?(:load)
end
