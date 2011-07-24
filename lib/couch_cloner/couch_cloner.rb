module CouchCloner
  def self.included(base)
    base.send :include, Recloner
  end
end
