module CouchCloner
  module Scheduling
    def self.included(base)
      base.extend   ClassMethods
      base.property :start, Time
      base.view_by  :clone_id_and_start, :map => "
        function(doc){
          if(doc['couchrest-type'] == '#{base}'){
            emit([doc.clone_id, doc.start], null);
          }
        }
      ", :reduce => "_count"
      base.validate :uniqueness_of_start_and_clone_id
    end
    
    module ClassMethods
      def count_by_clone_id_and_start(options={})
        result = by_clone_id_and_start(options.merge(:reduce => true))['rows'].first
        result ? result['value'] : 0
      end
    end

    private
    def uniqueness_of_start_and_clone_id
      if !start.nil? && self.class.count_by_clone_id_and_start(:key => [clone_id, start]) != 0
        errors.add :start, "must be unique for the clone_id group '#{clone_id}'"
      end
    end
  end
end
