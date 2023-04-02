# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)

# Describe your gem and declare its dependencies:
Gem::Specification.new do |gem|
  gem.name        = 'graphoid'
  gem.version     = '0.1.1'
  gem.authors     = ['Maximiliano Perez Coto']
  gem.email       = ['maxiperezc@gmail.com']
  gem.homepage    = 'https://github.com/maxiperezc/graphoid'
  gem.summary     = 'Generates a GraphQL API from Rails ActiveRecord or Mongoid'
  gem.description = 'A gem that helps you autogenerate a GraphQL API from Mongoid or ActiveRecord models.'
  gem.license     = 'MIT'

  gem.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']

  gem.add_dependency 'graphql', '~> 1'
  gem.add_dependency 'rails', '~> 5'
end
