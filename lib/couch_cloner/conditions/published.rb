module CouchCloner
  module Conditions
    module Published
      def conditions
        "#{super} && doc.milestone_memories.length > 0"
      end
    end
  end
end
