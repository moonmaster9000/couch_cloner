module CouchCloner
  class ByCloneIdAndStartTime
    include CouchView::Map

    def map
      "
        function(doc){
          if (#{conditions} && (doc.start == null || doc.start == '')) {
            emit([doc.clone_id, {'created_at': doc.created_at}], null)
          } else if (#{conditions} && doc.start != null && doc.start != ''){
            emit([doc.clone_id, doc.start], null)
          }
        }
      "
    end
  end
end
