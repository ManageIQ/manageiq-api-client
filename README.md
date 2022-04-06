# ManageIQ API Client

[![Gem Version](https://badge.fury.io/rb/manageiq-api-client.svg)](http://badge.fury.io/rb/manageiq-api-client)
[![CI](https://github.com/ManageIQ/manageiq-api-client/actions/workflows/ci.yaml/badge.svg)](https://github.com/ManageIQ/manageiq-api-client/actions/workflows/ci.yaml)
[![Code Climate](https://codeclimate.com/github/ManageIQ/manageiq-api-client.svg)](https://codeclimate.com/github/ManageIQ/manageiq-api-client)
[![Test Coverage](https://codeclimate.com/github/ManageIQ/manageiq-api-client/badges/coverage.svg)](https://codeclimate.com/github/ManageIQ/manageiq-api-client/coverage)

This gem provides Ruby access to the ManageIQ API by exposing the ManageIQ
collections, resources and related actions as Ruby objects and equivalent methods.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'manageiq-api-client'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install manageiq-api-client

## Usage

```ruby
miq = ManageIQ::API::Client.new(
  :url      => "http://localhost:3000",
  :user     => "user",
  :password => "password"
)

miq.vms.where(:id => 320).first.start

miq.vms.limit(5).each do |vm|
  vm.suspend if vm.hardware.memory_mb >= 8192
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ManageIQ/manageiq-api-client.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

