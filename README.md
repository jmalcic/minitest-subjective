# Minitest Subjective

Is your testing [sociable](https://martinfowler.com/bliki/UnitTest.html#SolitaryOrSociable)?
If so, test coverage you collect when running all your tests together will be artifically inflated.
That's because coverage only reflects the fact that _something, somewhere_ touched the covered code,
not necessarily your well-designed test for that specific method, alas.
What would be great is a kind of coverage sensitive to the current test _subject_ as it changes while running tests.

This has been [discussed before](https://www.rubyevents.org/talks/improving-coverage-analysis) by Ryan Davis,
author of Minitest, and you should totally watch his talk to understand why this matters, and why he created
[`minitest-coverage`](https://github.com/minitest/minitest-coverage). That was a while ago, and Ruby now has
more coverage modes (e.g. branch coverage, very useful). This gem takes a different approach to the problem, which also
avoids needing any changes to the coverage API.

The premise is straightforward: where $c_0$ is the coverage after first loading a file (before running any tests),
$c_1$ is the coverage just before running tests _for that file in particular_,
and $c_2$ is the coverage after running the last test for that file,
coverage for that file can be expressed as:
$$c_0 + (c_2 - c_1)$$
This gem just implements addition and subtraction for the different kinds of coverage in coverage results,
plus a basic formatter so you can see the results.
It works with parallel testing, and isn't thread-safe because coverage can't be run per-thread anyway.

## Installation

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add minitest-subjective
```

## Usage

Simply run your tests with the `--subjective` flag.

```bash
minitest --subjective
```

Works with Rails too.

```bash
rails t --subjective
```

If you can't easily pass the flag, you can set `MINITEST_SUBJECTIVE=1` instead.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests.
You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.
To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`,
which will create a git tag for the version, push git commits and the created tag,
and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jmalcic/minitest-subjective.
This project is intended to be a safe, welcoming space for collaboration,
and contributors are expected to adhere to the [Ruby code of conduct](https://www.ruby-lang.org/en/conduct/).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Minitest::Subjective project's codebases, issue trackers, chat rooms and mailing lists
is expected to follow the [code of conduct](https://www.ruby-lang.org/en/conduct/).
