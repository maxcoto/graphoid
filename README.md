# Graphoid
This gem is used to generate a full GraphQL api using introspection of MongoId models.

## Dependency
This gem depends on the graphql gem for rails https://github.com/rmosolgo/graphql-ruby
So it is required to have it and install it using
```bash
rails generate graphql:install
```

## Usage
Require all the models in which you want to have basic find one, find many, create, update and delete actions on.

Create the file `config/initializers/Graphoid.rb`

And require the models like this:

```ruby
Graphoid.configure do |config|
  config.driver = :mongoid
  config.driver = :active_record
end
Graphoid.initialize
```

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'graphoid'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install graphoid
```

Then you can determine which queries and mutations should be created in `app/graphql/types/query_type.rb`

```ruby
include Graphoid::Queries
include Graphoid::Mutations
```

And which mutations should be created in `app/graphql/types/mutation_type.rb`

```ruby
include Graphoid::Graphield
```

## Contributing
Figure out the driver
Functionality to sort top level models by association values
Filter by Array or Hash => The cases are failing, implementation correction needed.

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
