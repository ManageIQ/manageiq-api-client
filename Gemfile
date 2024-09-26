source 'https://rubygems.org'

# Specify your gem's dependencies in manageiq-api-client.gemspec
gemspec

# Load developer specific Gemfile
dev_gemfile = File.expand_path("Gemfile.dev.rb", __dir__)
eval_gemfile(dev_gemfile) if File.exist?(dev_gemfile)

minimum_version =
  case ENV['TEST_RAILS_VERSION']
  when "7.2"
    "~>7.2.1"
  when "7.1"
    "~>7.1.4"
  else
    "~>7.0.8"
  end

gem "activesupport", minimum_version
