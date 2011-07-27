module CouchCloner
  module Clone
    def self.included(base)
      base.property :clone_id
      base.send     :include, InstanceMethods
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
