module CouchCloner
  def clone(&block)
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
    block ||= Proc.new {}
    next_id = database.server.next_uuid 
    copy next_id
    self.class.get(next_id).tap(&block).tap {|d| d.save}
  end
end
