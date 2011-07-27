$LOAD_PATH.unshift "./lib"

require 'couch_cloner'
require 'couchrest_model_config'
require 'couch_publish'
require 'timecop'

CouchRest::Model::Config.edit do
  database do
    default "http://admin:password@localhost:5984/couch_cloner_test"
  end
end

Before do
  CouchRest::Model::Config.default_database.recreate!
end
