# Bundler::Changelogs

A bundler plugin that shows changelogs of your gem dependencies that specify changelog urls [not yet filtered to git version updates].

The changelog_uri would be specified in the 'metadata' section of a gemspec. Not many gems do this, tho

## Installation

    $ bundle plugin install bundler-changelogs

## Usage

    $ bundle changelogs

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. 

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jdar/bundler-changelogs.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
