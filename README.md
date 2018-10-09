# ScenicOracleEnhancedAdapter

This gem provides an adapter for the [Scenic gem](https://github.com/thoughtbot/scenic) for use with the [Oracle Enhanced Adapter](https://github.com/rsim/oracle-enhanced/).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'scenic_oracle_enhanced_adapter'
```

And then execute:

    $ bundle

Then add a Scenic initializer (or modify your existing initializer) to make Scenic use this adapter:

```
# config/initializers/scenic.rb

Scenic.configure do |config|
  config.database = Scenic::Adapters::OracleEnhanced.new
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/PMACS/scenic_oracle_enhanced_adapter.
