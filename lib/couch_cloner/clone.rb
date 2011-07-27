module CouchCloner
  module Clone
    def self.included(base)
      base.property :clone_id
      base.send :include, InstanceMethods
      base.extend ClassMethods

      base.view_by :clone_id, :map => "
        function(doc){
          if (doc['couchrest-type'] == '#{base}')
            emit(doc.clone_id, null)
        }
      ", :reduce => "_count"

      base.view_by :clone_id_and_start_time, :map => "
        function(doc){
          if (doc['couchrest-type'] == '#{base}' && (doc.start == null || doc.start == '')) {
            emit([doc.clone_id, {'created_at': doc.created_at}], null)
          } else if (doc['couchrest-type'] == '#{base}' && doc.start != null && doc.start != ''){
            emit([doc.clone_id, doc.start], null)
          }
        }
      ", :reduce => "_count"
    end

    module ClassMethods
      def count_by_clone_id(options={})
        result = by_clone_id(options.merge(:reduce => true))['rows'].first
        result ? result['value'] : 0
      end

      def by_clone_id_and_start(*args)
        if args.length == 2
          clone_id = args.first
          options  = args.last
        elsif args.length == 1
          options = args.first.kind_of?(Hash) ? args.first : {}
          clone_id = args.first.kind_of?(Hash) ? nil : args.first
        else
          raise ArgumentError, "wrong number of arguments"
        end
        
        options[:startkey] ||= [clone_id, nil]
        options[:endkey]   ||= [clone_id, {:end => nil}]
        by_clone_id_and_start_time options
      end
    end

    module InstanceMethods
      def clone(&block)
        verify_clone_preconditions
        block ||= Proc.new {}
        
        property_names = properties.map(&:name) - (protected_properties.map(&:name) + %w{_id _attachments _rev milestone_memories})
        attrs = property_names.inject({}){|hash, x| 
          val = send(x)
          val = val.to_a if val.class == CouchRest::Model::CastedArray
          hash[x] = val
          hash
        }

        self.class.new(attrs).tap(&block)
       end
      
      def clone!(&block)
        verify_clone_preconditions
        has_block = !block.nil?
        block ||= Proc.new {}
        next_id = database.server.next_uuid 
        copy next_id
        doc = self.class.get(next_id)
        has_block ? doc.tap(&block).tap {|d| d.save} : doc
      end

      private
      def verify_clone_preconditions
        unless self.clone_id
          raise "You must specify a non-nil clone_id on your '#{self.class}' instance before you can clone it."
        end
      end
    end
  end
end