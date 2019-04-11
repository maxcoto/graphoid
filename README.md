
<img src="https://d3a1eqpdtt5fg4.cloudfront.net/items/1W3T1M3w3P053u2U411r/Ruby_On_Rails_Logo.svg.png" height="150" alt="graphoid"/>

[![Build Status](https://travis-ci.org/maxiperezc/graphoid.svg?branch=master)](https://travis-ci.org/maxiperezc/graphoid)
[![Gem Version](https://badge.fury.io/rb/graphoid.svg)](https://rubygems.org/gems/graphoid)

This gem is used to generate a full GraphQL API using introspection of Mongoid or ActiveRecord models.
After installing it, you will have create, update, delete, and query actions on any rails models you want.

## Dependency
This gem depends on the graphql gem for rails https://github.com/rmosolgo/graphql-ruby
So please install that gem first before continuing

## Installation
Add this line to your Gemfile:

```ruby
gem 'graphoid'
```

```bash
$ bundle install
```

## Configuration
Create the file `config/initializers/graphoid.rb`
And configure the database you want to use in it.

```ruby
Graphoid.configure do |config|
  config.driver = :mongoid
  # or
  config.driver = :active_record
end
```

## Usage
You can determine which models will be visible in the API by including the Graphoid Queries and Mutations

```ruby
class Person
  include Graphoid::Queries
  include Graphoid::Mutations
end
```

You can also include a special concern that will let you create virtual fields and forbid access to existing fields
```ruby
class Person
  include Graphoid::Graphield

  graphield :full_name, String # virtual fields need to resolve as a method
  graphorbid :balance # attribute balance will not be exposed in the API

  def full_name
    "#{first_name} #{last_name}"
  end
end
```

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

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
