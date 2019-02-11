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

## Switching from rails_sql_views to Scenic

In Oracle 12, replacing a view has issues when the view refers to objects outside its own schema; use update_view, which will drop and create. The replace_view method can still be used for views referring to objects in their own schema.

1. Run `bundle exec rails g scenic:view <full_view_name>` (if you use a prefix for the view, include it).
1. Move the view's SQL definition from the original migration into the newly-created file in db/views.
1. In the original migration, delete any drop_view call.
1. Copy the create_view or update_view line from the scenic migration and substitute it for the old create_view method and block.
1. Delete the scenic migration file
1. For the down method, copy the update_view line into the down (replacing any drop_ and create_view methods) and make the version: argument to the same number as the revert_to_version: argument (e.g. `update_view :complex_data_view, version: 2, revert_to_version: 1` becomes `update_view :complex_data_view, version: 1, revert_to_version: 1`)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/PMACS/scenic_oracle_enhanced_adapter.
