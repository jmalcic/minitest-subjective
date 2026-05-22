# frozen_string_literal: true

module Minitest
  module Subjective
    class Reporter < Minitest::Reporter # :nodoc:
      attr_accessor :results

      def initialize(io = $stdout, options = {})
        super
        self.results = {}
      end

      def record(result)
        merge_result(result)
      end

      def report
        results.each do |subject_name, result|
          io.puts
          io.puts "Coverage for #{subject_name}:"
          io.puts coverage_headline_for(result)
          io.puts result.to_s unless result.covered?
        end
      end

      private

      def coverage_headline_for(result)
        colors.format result.covered? ? :green : :red do
          result.covered? ? 'All covered!' : 'Coverage missing!'
        end
      end

      def colors
        @colors ||= Formatter::Colors.new
      end

      def merge_result(result)
        with_subject_name_for(result) do |subject_name|
          results[subject_name] ||= Subjective.load_results[subject_name] || result.load_result
          results[subject_name] = if results[subject_name]
                                    results[subject_name] + result.coverage_result
                                  else
                                    result.coverage_result
                                  end
        end
      end

      def with_subject_name_for(result)
        CaseInquirer.new(result.klass).tap do |inquirer|
          next unless inquirer.subject_file

          yield inquirer.subject_name
        end
      end
    end
  end
end
