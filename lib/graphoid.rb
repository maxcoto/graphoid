# frozen_string_literal: true

require 'graphoid/utils'
require 'graphoid/grapho'
require 'graphoid/mapper'
require 'graphoid/config'
require 'graphoid/scalars'
require 'graphoid/argument'
require 'graphoid/graphield'

require 'graphoid/operators/attribute'
require 'graphoid/operators/relation'
require 'graphoid/operators/inherited/belongs_to'
require 'graphoid/operators/inherited/embeds_one'
require 'graphoid/operators/inherited/embeds_many'
require 'graphoid/operators/inherited/has_many'
require 'graphoid/operators/inherited/has_one'
require 'graphoid/operators/inherited/many_to_many'

require 'graphoid/queries/queries'
require 'graphoid/queries/processor'
require 'graphoid/queries/operation'

require 'graphoid/mutations/create'
require 'graphoid/mutations/update'
require 'graphoid/mutations/delete'
require 'graphoid/mutations/processor'
require 'graphoid/mutations/structure'

require 'graphoid/drivers/mongoid'
require 'graphoid/drivers/active_record'

require 'graphoid/definitions/types'
require 'graphoid/definitions/sorter'
require 'graphoid/definitions/filters'
require 'graphoid/definitions/inputs'

require 'graphoid/main'
