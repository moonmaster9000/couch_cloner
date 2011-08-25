module CouchCloner
  module Conditions
    module Shown
      def conditions
        "#{super} && doc.couch_visible == true"
      end
    end
  end
end
