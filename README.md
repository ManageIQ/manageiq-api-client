# ManageIQ::Api::Client

Welcome to the ManageIQ::Api::Client Gem.

This Gem provides Ruby access to the ManageIQ Rest API buy exposing the ManageIQ 
collections, resources and related actions as ruby objects and equivalent methods.

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

  miq = ManageIQ::Api::Client.new(:url => "http://localhost:3000", :username => "user", :password => "user_password")

  myvm = miq.vms[320]

  myvm.start

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/manageiq-api-client.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

