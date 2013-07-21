require 'cinch'
require "mongo"
require "time"

module Mongo::PubSub
  class Subscriber
    def initialize(bot, collection_name)
      @bot = bot
      connection = Mongo::Connection.new('127.0.0.1', 27017)
      # TODO: from config
      db = connection.db("pubsub") 
      @subscribed_collection = db.collection(collection_name)
    end

    def start
      tail = Mongo::Cursor.new(@subscribed_collection,
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
            @bot.channels.each do | channel |
              @bot.handlers.dispatch(:notice_message, nil, channel, doc['message'], doc['formats'] || {})
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
      listen_to :notice_message
      def listen(m, channel, message, formats = {})
        lines = message.rstrip.split(/\r?\n/).map {|line| line.chomp }
        messages = []
        lines.each_with_index do |line, i|
          format = formats[i.to_s] || []
          format = format.map{|f| f.to_sym }
          messages << Cinch::Formatting::format(*format, line)
        end
        channel.notice messages.join(" ")
        # channel.notice Cinch::Formatting::format(:bold, :orange, line)
      end
    end
  end
end
