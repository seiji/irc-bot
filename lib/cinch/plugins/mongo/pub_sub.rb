require 'cinch'
require "mongo"
require "time"

module Mongo::PubSub
  class Subscriber
    def initialize(bot)
      @bot = bot
      connection = Mongo::Connection.new('127.0.0.1', 27017)
      # TODO: from config
      db = connection.db("pubsub") 
      @subscribed_collection = db.collection("messages")
      @earliest = @subscribed_collection.find_one({}, :sort => [[ '$natural', -1 ]])['_id']
    end

    def start
      tail = Mongo::Cursor.new(@subscribed_collection,
                               selector: {
                                 'time' => {'$gt' => (Time.now.to_f * 1000.0).to_i}
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
            @bot.channels.each do | channel |
              @bot.handlers.dispatch(:random_number, nil, channel, doc['message'])
            end
          rescue EndSubscriptionException
            break
          end
        end
      end
    end
  end
end

module Cinch::Plugins
  module Mongo
    class PubSub
      include Cinch::Plugin
      set :help, <<-HELP
pubsub
HELP
      listen_to :random_number
      def listen(m, channel, message)
        channel.notice message
      end

      private
    end
  end
end
