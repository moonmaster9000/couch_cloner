Gem::Specification.new do |s|
  s.name        = "couch_cloner"
  s.version     = File.read "VERSION"
  s.authors     = "Matt Parker"
  s.homepage    = "http://github.com/moonmaster9000/couch_cloner"
  s.summary     = "Clone and schedule CouchDB documents"
  s.description = "Create clones of CouchDB documents, and schedule them for publication."
  s.email       = "moonmaster9000@gmail.com"
  s.files       = Dir["lib/**/*"] << "VERSION" << "readme.markdown" << "couch_cloner.gemspec"
  s.test_files  = Dir["feature/**/*"]

  s.add_development_dependency "cucumber"
  s.add_development_dependency "rspec"
  s.add_development_dependency "couchrest_model_config"
  s.add_development_dependency "couch_publish", "~> 0.0.3"
  s.add_development_dependency "couch_visible"
  s.add_development_dependency "timecop"
  
  s.add_dependency             "couchrest",       "1.0.1"
  s.add_dependency             "couchrest_model", "~> 1.0.0"
  s.add_dependency             "recloner",        "~> 0.1.1"
  s.add_dependency             "couch_view",      "~> 0.0.3"
end
