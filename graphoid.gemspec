$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "graphoid/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |gem|
  gem.name        = "graphoid"
  gem.version     = Graphoid::VERSION
  gem.authors     = ["Maximiliano Perez Coto"]
  gem.email       = ["maxiperezc@gmail.com"]
  gem.homepage    = "http://www.maxiperezcoto.com"
  gem.summary     = "Generate GraphQL from ActiveRecord"
  gem.description = "A gem that helps you autogenerate a GraphQL api from MongoId models."
  gem.license     = "MIT"

  gem.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  gem.executables = ["graphoid"]
  gem.add_dependency "rails", "~> 5.1.0"
  gem.add_development_dependency "sqlite3"
  gem.add_development_dependency 'rspec-collection_matchers'
end
