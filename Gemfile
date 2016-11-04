source 'https://rubygems.org'

# Specify your gem's dependencies in manageiq-api-client.gemspec
gemspec

group :test do
  gem "simplecov", :require => false
  gem "codeclimate-test-reporter", "~> 1.0.0", :require => false
end

# Move query_relation declaration to gemspec once published
gem "query_relation", :git => "https://github.com/ManageIQ/query_relation.git", :branch => "master"

# Load developer specific Gemfile
dev_gemfile = File.expand_path("Gemfile.dev.rb", __dir__)
eval_gemfile(dev_gemfile) if File.exist?(dev_gemfile)
