#! ruby
require "cinch"
require 'bundler'
Bundler.require(:default)
$:.unshift 'lib'

require 'cinch/plugins/http/info'
require 'cinch/plugins/mongo/pub_sub'
require 'cinch/plugins/openweathermap'

bot = Cinch::Bot.new do
  configure do |c|
    c.server = "chat.freenode.net"
    c.nick = "_binch"
    c.channels = ["#bam1"]
    c.plugins.plugins = [
                         Cinch::Plugins::HTTP::Info,
                         Cinch::Plugins::Mongo::PubSub
                        ]
  end
end

Thread.new { Mongo::PubSub::Subscriber.new(bot, "bami1").start }
bot.start
