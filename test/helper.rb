require 'rubygems'
require 'bundler'

ENV['RAILS_ENV'] = 'test'
require "dummy/config/environment"
require "rails/test_help"

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'test/unit'
require 'shoulda'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'wisepdf'

class Test::Unit::TestCase
end
