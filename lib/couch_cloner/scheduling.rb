module CouchCloner
  module Scheduling
    def self.included(base)
      base.property :start, Time
      base.validate :uniqueness_of_start_and_clone_id
    end
    
    private
    def uniqueness_of_start_and_clone_id
      if !start.nil? && self.class.count_by_clone_id_and_start_time.key([clone_id, start]).get! != 0
        errors.add :start, "must be unique for the clone_id group '#{clone_id}'"
      end
    end
  end
end
