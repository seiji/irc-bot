#! ruby
require "cinch"
require 'bundler'
Bundler.require(:default)
$:.unshift 'lib'

require "mongo"
require 'cinch/plugins/github/status'
require 'cinch/plugins/http/info'
require 'cinch/plugins/mongo/pub_sub'
require 'cinch/plugins/urbandictionary'

bot = Cinch::Bot.new do
  configure do |c|
    c.server = "chat.freenode.net"
    c.nick = "_binch"
    c.channels = ["#seijit"]
    c.plugins.plugins = [
                         Cinch::Plugins::Github::Status,
                         Cinch::Plugins::HTTP::Info,
                         Cinch::Plugins::Mongo::PubSub,
                         Cinch::Plugins::Urbandictionary
                        ]
  end
end

Thread.new { Mongo::PubSub::Subscriber.new(bot, "seijit").start }
bot.start
