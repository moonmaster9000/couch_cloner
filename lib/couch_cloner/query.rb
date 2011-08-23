module CouchCloner
  module Query
    def self.included(base)
      base.extend ClassMethods
      base.map :clone_id
      base.couch_view :by_clone_id_and_start_time do
        map CouchCloner::ByCloneIdAndStartTime
      end
    end

    module ClassMethods
      def map_by_clone_id_and_start(clone_id, start=nil)
        map_by_clone_id_and_start_time.startkey!([clone_id, start]).endkey!([clone_id, {:end => nil}])
      end
      
      def count_by_clone_id_and_start(clone_id, start=nil)
        count_by_clone_id_and_start_time.
          startkey!([clone_id, start]).
          endkey!([clone_id, {:end => nil}])
      end

      def map_active_by_clone_id(clone_id)
        map_by_clone_id_and_start_time.
          startkey!([clone_id, Time.now]).
          endkey!([clone_id]).
          descending!(true)
      end

      def map_future_by_clone_id(clone_id)
        map_by_clone_id_and_start_time.
          startkey!([clone_id, Time.now]).
          endkey!([clone_id, {:end => nil}])
      end
      
      #new
      def count_future_by_clone_id(clone_id)
        count_by_clone_id_and_start_time.
          startkey!([clone_id, Time.now]).
          endkey!([clone_id, {:end => nil}])
      end

      def map_past_by_clone_id(clone_id)
        map_by_clone_id_and_start_time.
          startkey!([clone_id, Time.now]).
          endkey!([clone_id]).
          descending!(true)
      end

      def count_past_by_clone_id(clone_id)
        count_by_clone_id_and_start_time.
          startkey!([clone_id, Time.now]).
          endkey!([clone_id]).
          descending!(true)
      end

      def map_clone_ids
        map_by_clone_id.
          reduce!(true).
          group!(true)
      end

      def count_clone_ids!
        map_by_clone_id.
          reduce!(true).
          group!(true).get!['rows'].count
      end

      def map_last_future_by_clone_id(clone_id)
        map_by_clone_id_and_start_time.
          startkey!([clone_id, {:end => nil}]).
          endkey!([clone_id]).
          descending!(true).
          limit!(1)
      end
    end
  end
end
