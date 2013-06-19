require "mongo"
include Mongo

namespace :mongo do
  desc "setup"
  task :setup do |t|
    # TODO get from config
    mongo_client = MongoClient.new("localhost", 27017)
    db = mongo_client.db("pubsub")
    db.create_collection("messages", capped: true, size: 10000000, max: 1000)
  end
end
