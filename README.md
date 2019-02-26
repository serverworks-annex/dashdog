# Dashdog

[![Gem Version](https://badge.fury.io/rb/dashdog.svg)](https://badge.fury.io/rb/dashdog)

Datadog dashboards management tool with Ruby DSL.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'dashdog'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install dashdog

## Usage

Please set your API,Application key in  the environment variables.

```sh
export DD_API_KEY=<your-datadog-api-key>
export DD_APP_KEY=<your-datadog-application-key>
```

Available commands:

```
Commands:
  dashdog apply           # Apply the dashboard configurations
  dashdog export          # Export the dashboard configurations
  dashdog help [COMMAND]  # Describe available commands or one specific command

Options:
  -f, [--file=FILE]  # Configuration file
                     # Default: Boardfile
      [--color], [--no-color]  # Disable colorize
                               # Default: true
```

## Commands

### export
Export the dashboard configurations

```sh
Usage:
  dashdog export

Options:
  -w, [--write], [--no-write]  # Write the configuration to the file
      [--split], [--no-split]  # Split configuration file
  -f, [--file=FILE]            # Configuration file
                               # Default: Boardfile
      [--color], [--no-color]  # Disable colorize
                               # Default: true
```

### apply
Apply the dashboard configurations

```sh
Usage:
  dashdog apply

Options:
  -d, [--dry-run], [--no-dry-run]            # Dry run (Only display the difference)
      [--force-create], [--no-force-create]  # Force to create new dashboard
  -f, [--file=FILE]                          # Configuration file
                                             # Default: Boardfile
      [--color], [--no-color]                # Disable colorize
                                             # Default: true
  -e, [--exclude-title=EXCLUDE_TITLE]        # Exclude patterns of title
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/serverworks/dashdog.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Copyright

Copyright (c) 2016-2018 Serverworks Co.,Ltd. See [LICENSE](https://github.com/serverworks/dashdog/blob/master/LICENSE.txt) for details.
