
<img src="https://d3a1eqpdtt5fg4.cloudfront.net/items/0T0M3O2R1q2W3i1p3e0A/graphoid.png" height="150" alt="graphoid"/>

[![Build Status](https://travis-ci.org/maxiperezc/graphoid.svg?branch=master)](https://travis-ci.org/maxiperezc/graphoid)
[![Gem Version](https://badge.fury.io/rb/graphoid.svg)](https://rubygems.org/gems/graphoid)

Generates a full GraphQL API using introspection of Mongoid or ActiveRecord models.

## API Dodocumentation
The [API Documentation](https://maxiperezc.github.io/graphoid/) that displays how to use the queries and mutations that Graphoid automatically generates.


## Dependency
This gem depends on [the GraphQL gem](https://github.com/rmosolgo/graphql-ruby).
Please install that gem first before continuing

## Installation
Add this line to your Gemfile:

```ruby
gem 'graphoid'
```

```bash
$ bundle install
```

## Database
Create the file `config/initializers/graphoid.rb`
And configure the database you want to use in it (:mongoid or :active_record)

```ruby
Graphoid.configure do |config|
  config.driver = :mongoid
end
```

## Usage
You can determine which models will be visible in the API by including the Graphoid Queries and Mutations concerns

```ruby
class Person
  include Graphoid::Queries
  include Graphoid::Mutations
end
```

## Examples
You can find an example that uses ActiveRecord in the [Tester AR folder](https://github.com/maxiperezc/graphoid/tree/master/spec/tester_ar)  
And an example with Mongoid in the [Tester Mongo folder](https://github.com/maxiperezc/graphoid/tree/master/spec/tester_mongo)  
In this same repository.

## Contributing
- Install code climate
- Functionality to sort top level models by association values
- Filter by Array or Hash.
- Fix Rubocop errors.
- Live Reload
- AR eager load
- Relation with aliases tests
- Aggregations
- Remove config / auto-setup AR-Mongo
- Write division for "every" in Mongoid and AR
- Permissions on fields
- has_one_through implementation
- has_many_selves (employee) tests
- has_and_belongs_to_many_selves (followers) tests
- Embedded::Many filtering implementation
- Embedded::One filtering with OR/AND

## Testing
```bash
$ DRIVER=ar DEBUG=true bundle exec rspec
$ DRIVER=mongo DEBUG=true bundle exec rspec
```

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
