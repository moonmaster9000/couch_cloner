module CouchCloner
  def self.included(base)
    base.send :include, CouchView unless base.ancestors.include?(CouchView)
    base.send :include, CouchCloner::Clone
    base.send :include, CouchCloner::Scheduling
    base.send :include, CouchCloner::Query
    
    if defined?(::CouchPublish) && base.ancestors.include?(::CouchPublish)
      base.send :include, CouchCloner::CouchPublish
    end

    if defined?(::CouchVisible) && base.ancestors.include?(::CouchVisible)
      base.send :include, CouchCloner::CouchVisible
    end
  end
end
