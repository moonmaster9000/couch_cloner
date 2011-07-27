module CouchCloner
  module Query
    def self.included(base)
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
      def clone_ids(options={})
        by_clone_id(options.merge(:reduce => true, :group => true))['rows'].collect {|result| result['key']}
      end
      
      #TODO: is there a way to get a count on a :group :reduce query without returning the actual results?
      def count_clone_ids(options={})
        clone_ids(options).count
      end

      def active_by_clone_id(clone_id)
        result = self.by_clone_id_and_start(:startkey => [clone_id, Time.now], :descending => true, :limit => 1).first
        result && result.clone_id == clone_id ? result : nil
      end
      
      def count_by_clone_id(options={})
        result = by_clone_id(options.merge(:reduce => true))['rows'].first
        result ? result['value'] : 0
      end

      def count_active_and_future_clones_by_clone_id(clone_id)
        future_count = count_by_clone_id_and_start(:startkey => [clone_id, Time.now + 1.second])
        active_count = active_by_clone_id(clone_id) ? 1 : 0
        active_count + future_count
      end
      
      def count_past_clones_by_clone_id(clone_id)
        result = by_clone_id_and_start(:startkey => [clone_id, Time.now], :descending => true, :reduce => true)['rows'].first
        result = result ? (result['value'] - 1) : 0
        result = 0 if result < 0
        result
      end

      def past_clones_by_clone_id(clone_id)
        by_clone_id_and_start(:startkey => [clone_id, Time.now], :descending => true)[1..-1]
      end

      def active_and_future_clones_by_clone_id(clone_id)
        [active_by_clone_id(clone_id)] + by_clone_id_and_start(:startkey => [clone_id, Time.now + 1.second])
      end

      def by_clone_id_and_start(*args)
        clone_id, options = parse_clone_id_and_start_arguments *args

        unless options[:key]
          options[:startkey] ||= [clone_id, nil]
          if !options[:endkey] 
            options[:endkey] = [options[:startkey].first, nil]           if     options[:descending]
            options[:endkey] = [options[:startkey].first, {:end => nil}] unless options[:descending]
          end
        end

        by_clone_id_and_start_time options
      end
      
      def count_by_clone_id_and_start(*args)
        clone_id, options = parse_clone_id_and_start_arguments *args

        result = by_clone_id_and_start(clone_id, options.merge(:reduce => true))['rows'].first
        result ? result['value'] : 0
      end

      private
      def parse_clone_id_and_start_arguments(*args)
        if args.length == 2
          clone_id = args.first
          options  = args.last
        elsif args.length == 1
          options = args.first.kind_of?(Hash) ? args.first : {}
          clone_id = args.first.kind_of?(Hash) ? nil : args.first
        else
          raise ArgumentError, "wrong number of arguments"
        end

        [clone_id, options]
      end
    end

  end
end
