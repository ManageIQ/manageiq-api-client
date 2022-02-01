source 'https://rubygems.org'

# Specify your gem's dependencies in manageiq-api-client.gemspec
gemspec

# Load developer specific Gemfile
dev_gemfile = File.expand_path("Gemfile.dev.rb", __dir__)
eval_gemfile(dev_gemfile) if File.exist?(dev_gemfile)

case ENV['TEST_RAILS_VERSION']
when "6.0"
  gem "activesupport", "~>6.0.4"
when "6.1"
  gem "activesupport", "~>6.1.4"
end
