# frozen_string_literal: true

# Load the Rails application.
require_relative 'application'

# Initialize the Rails application.
Rails.application.initialize!

if ENV["RAILS_ENV"] == "test"
  puts "creating sqlite in memory database"
  APP_ROOT = Pathname.new File.expand_path('..', __dir__)
  load "#{APP_ROOT}/db/schema.rb" # use db agnostic schema by default
  # ActiveRecord::Migrator.up('db/migrate') # use migrations
end
