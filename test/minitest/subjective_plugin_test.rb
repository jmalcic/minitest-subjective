# frozen_string_literal: true

require 'test_helper'

module Minitest
  class SubjectivePluginTest < Minitest::Test
    setup do
      @output = StringIO.new(''.encode('UTF-8'))
      @custom_reporter = Minitest::Reporter.new(@output)
    end

    test 'appends reporter' do
      with_plugin '--subjective' do
        refute_empty Minitest.reporter.reporters.grep(Subjective::Reporter)
      end
    end

    test 'keeps summary reporter' do
      with_plugin '--subjective' do
        refute_empty Minitest.reporter.reporters.grep(Minitest::SummaryReporter)
      end
    end

    test 'keeps progress reporter' do
      with_plugin '--subjective' do
        refute_empty Minitest.reporter.reporters.grep(Minitest::ProgressReporter)
      end
    end

    test 'keeps non-default reporters' do
      with_plugin '--subjective', initial_reporters: [@custom_reporter] do
        assert_includes Minitest.reporter.reporters, @custom_reporter
      end
    end

    test 'does not add reporter unless option enabled' do
      with_plugin do
        assert_empty Minitest.reporter.reporters.grep(Subjective::Reporter)
      end
    end

    test 'does not add reporter unless ENV var present' do
      ENV['MINITEST_SUBJECTIVE'] = '1'

      with_plugin do
        refute_empty Minitest.reporter.reporters.grep(Subjective::Reporter)
      end
      ENV.delete 'MINITEST_SUBJECTIVE'
    end

    private

    def baseline_reporters
      [Minitest::SummaryReporter.new(@output), Minitest::ProgressReporter.new(@output)]
    end

    def with_plugin(*args, initial_reporters: baseline_reporters)
      original_reporter = Minitest.reporter
      Minitest.reporter = Minitest::CompositeReporter.new(*initial_reporters)

      with_stubs do
        Minitest.plugin_subjective_init(Minitest.process_args(args))

        yield
      end
    ensure
      Minitest.reporter = original_reporter
    end

    def with_stubs(&block)
      Subjective::TestExtensions.stub :prepend_target, nil do
        Subjective::ResultExtensions.stub :prepend_target, nil do
          Subjective.stub :start_coverage, true, &block
        end
      end
    end
  end
end
