module CouchCloner
  module CouchVisible
    def self.included(base)
      base.map :clone_id do
        conditions CouchCloner::Conditions::Shown, CouchCloner::Conditions::Hidden
      end

      base.couch_view :by_clone_id_and_start_time do
        map CouchCloner::ByCloneIdAndStartTime do
          conditions CouchCloner::Conditions::Shown, CouchCloner::Conditions::Hidden
        end
      end 
    end
  end
end
