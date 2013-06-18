require 'cinch'
require 'json'
require 'time'

module Cinch::Plugins
  module Github
    class Status
      include Cinch::Plugin

      self.help = "Show github status"
      
      match /github status/

      def execute(m)
        m.reply get_status
      end
      
      private
      def get_status
        http = Curl.get("https://status.github.com/api/status.json")
        body = http.body_str
        json = JSON.parser.new(http.body_str)
        d =  json.parse
        t = Time.parse("#{d['last_updated']}").getlocal
        "status: #{d['status']} (last_updated: #{t})"
      end
    end
  end
end
