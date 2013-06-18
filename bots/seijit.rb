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
    c.channels = ["#seijit"]
    c.plugins.plugins = [
                         Cinch::Plugins::Github::Status,
                         Cinch::Plugins::HTTP::Info
                        ]
  end
end

bot.start
