module CouchCloner
  def self.included(base)
    base.send :include, CouchCloner::Clone
    base.send :include, CouchCloner::Scheduling
  end
end
