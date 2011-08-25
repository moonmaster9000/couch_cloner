module CouchCloner
  module CouchPublish
    def self.included(base)
      base.map :clone_id do
        conditions CouchCloner::Conditions::Published, CouchCloner::Conditions::Unpublished
      end

      base.couch_view :by_clone_id_and_start_time do
        map CouchCloner::ByCloneIdAndStartTime
        conditions CouchCloner::Conditions::Published, CouchCloner::Conditions::Unpublished
      end
    end
  end
end
