# frozen_string_literal: true

module Graphoid
  module Utils
    class << self
      def modelize(text)
        graphqlize text.to_s.capitalize.camelize
      end

      def camelize(text)
        # we are doing it twice because _id gets translated to Id the first time and to id the second time.
        graphqlize text.to_s.camelize(:lower).camelize(:lower)
      end

      def graphqlize(text)
        text.to_s.gsub(/::/, '_')
      end

      def symbolize(fields)
        fields.keys.map(&:underscore).map(&:to_sym)
      end

      def underscore(props, fields = [])
        attrs = {}
        props.each do |key, value|
          key = key.underscore if fields.exclude?(key)
          attrs[key] = value
        end
        attrs
      end

      def build_update_attributes(data, model, context)
        user = context[:current_user]
        fields = Graphoid::Attribute.fieldnames_of(model)
        attrs = underscore(data, fields)
        attrs['updated_by_id'] = user.id if user && fields.include?('updated_by_id')
        attrs
      end
    end
  end
end
