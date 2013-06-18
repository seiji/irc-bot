#! ruby
require "cinch"
require 'bundler'
Bundler.require(:default)
$:.unshift 'lib'

require 'cinch/plugins/github/status'

bot = Cinch::Bot.new do
  configure do |c|
    c.server = "chat.freenode.net"
    c.nick = "cinch_github"
    c.channels = ["#seijit"]
    c.plugins.plugins = [Cinch::Plugins::Github::Status]
  end
end

bot.start
