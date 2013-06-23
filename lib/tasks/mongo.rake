require "mongo"
include Mongo

namespace :mongo do
  desc "setup"
  task :setup do |t|
    # TODO get from config
    mongo_client = MongoClient.new("localhost", 27017)
    db = mongo_client.db("pubsub")
    %w(seijit bami2 crashlogs).each do |n|
      db.create_collection(n, capped: true, size: 10000000, max: 1000)
    end
  end
end
