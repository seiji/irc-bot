#! ruby
require "cinch"
require 'bundler'
Bundler.require(:default)
$:.unshift 'lib'

require 'cinch/plugins/github/status'
require 'cinch/plugins/http/info'

bot = Cinch::Bot.new do
  configure do |c|
    c.server = "chat.freenode.net"
    c.nick = "_binch"
    c.channels = ["#bami2"]
    c.plugins.plugins = [
                         Cinch::Plugins::HTTP::Info
                        ]
  end
end

bot.start