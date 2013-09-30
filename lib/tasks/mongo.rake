require "mongo"
include Mongo

namespace :mongo do
  desc "setup"
  task :setup do |t|
    # TODO get from config
    client = MongoReplicaSetClient.new(
                                       ['irc.seiji.me:27017', 'bin.seiji.me:27017'],
                                       :read => :secondary
                                       )
    db = client.db("pubsub")
    %w(seijit bami2 crashlogs upcoming).each do |n|
      db.create_collection(n, capped: true, size: 10000000, max: 1000)
    end
  end

  desc "test"
  task :test do |t|
    client = MongoReplicaSetClient.new(
                                       ['irc.seiji.me:27017', 'bin.seiji.me:27017'],
                                       :read => :secondary
                                       )
    db = client.db("pubsub")
    c = db.collection('seijit')
    tail = Mongo::Cursor.new(c,
                               selector: {
                                 '_id' => {'$gt' => (Time.now.to_f * 1000.0).to_i}
                               },
                               timeout: false,
                               tailable: true,
                               order: [['$natural', 1]])

      tail.add_option(Mongo::Constants::OP_QUERY_AWAIT_DATA)
      while true
        sleep 5 
        doc = tail.next_document 
        if doc != nil 
          begin
            p doc
          rescue EndSubscriptionException
            break
          end
        end
        p 'a'
      end
  end
end
