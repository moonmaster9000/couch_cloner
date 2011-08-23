module CouchCloner
  def self.included(base)
    base.send :include, CouchView unless base.ancestors.include?(CouchView)
    base.send :include, CouchCloner::Clone
    base.send :include, CouchCloner::Scheduling
    base.send :include, CouchCloner::Query
  end
end
