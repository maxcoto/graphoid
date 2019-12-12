# frozen_string_literal: true

source 'https://rubygems.org'
ruby '2.6.5'

gemspec

gem 'graphql'
gem "nokogiri", ">= 1.10.4"

group :development, :test do
  gem 'byebug'
  gem 'simplecov', require: false
end

group :test do
  gem 'mongoid'
  gem 'mongoid-rspec'
  gem 'rspec'
  gem 'rspec-rails'
  gem 'sqlite3'
end
