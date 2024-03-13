if ENV['CI']
  require 'simplecov'
  SimpleCov.start
end

require 'webmock/rspec'

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'manageiq/api/client'

def api_file_fixture(path)
  File.read(File.join("spec/fixtures/api/", path))
end
