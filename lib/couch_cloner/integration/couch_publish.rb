module CouchCloner
  module CouchPublish
    def self.included(base)
      base.map :clone_id do
        conditions ::Published, ::Unpublished
      end

      base.couch_view :by_clone_id_and_start_time do
        map CouchCloner::ByCloneIdAndStartTime
        conditions ::Published, ::Unpublished
      end
    end
  end
end
