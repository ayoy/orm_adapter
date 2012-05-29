require 'dynamoid'

module Dynamoid
  module Document
    module ClassMethods
      include OrmAdapter::ToAdapter
    end
    
    class OrmAdapter < ::OrmAdapter::Base
      # Do not consider these to be part of the class list
      def self.except_classes
        @@except_classes ||= []
      end

      # Gets a list of the available models for this adapter
      def self.model_classes
        ObjectSpace.each_object(Class).to_a.select {|klass| klass.ancestors.include? Dynamoid::Document}
      end

      # get a list of column names for a given class
      def column_names
        klass.attributes.keys
      end

      # @see OrmAdapter::Base#get!
      def get!(id)
        record = klass.find_by_id(wrap_key(id))
        raise RecordNotFoundError unless record
        record
      end

      # @see OrmAdapter::Base#get
      def get(id)
        klass.find_by_id(wrap_key(id))
      end

      # @see OrmAdapter::Base#find_first
      def find_first(options)
        conditions, order = extract_conditions_and_order!(options)
        klass.where(conditions).first
        # klass.where(conditions_to_fields(conditions)).order_by(order).first
      end

      # @see OrmAdapter::Base#find_all
      def find_all(options)
        conditions, order = extract_conditions_and_order!(options)
        klass.where(conditions).all
      end

      # @see OrmAdapter::Base#create!
      def create!(attributes)
        klass.create!(attributes)
      end
  
    end
    
    class RecordNotFoundError < NotImplementedError
      def to_s
        "record not found"
      end
    end
  end
end
