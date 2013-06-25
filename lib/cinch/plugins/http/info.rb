require 'cinch'
require "curb"
require 'nokogiri'
require "uri"

module Cinch::Plugins
  module HTTP
    class Info
      include Cinch::Plugin

      BLACKLIST = [/\.png$/i, /\.jpe?g$/i, /\.bmp$/i, /\.gif$/i, /\.pdf$/i].freeze

      TITLE_ONLY_LIST = %w(twitter.com)
      
      set :help, <<-HELP
http[s]://..
parse html and show title, description
HELP
      match %r{(https?://.*?)(?:\s|$|,|#|\.\s|\.$)}, :use_prefix => false

      def execute(m, url)
        return if BLACKLIST.any?{|entry| url =~ entry}
        debug "match #{url}"
        get_info(url) do |msg|
          m.channel.notice msg
        end
      end

      private
      def get_info(url)
        http = Curl.get(url)
        html = Nokogiri::HTML(http.body_str)
        if node = html.at_xpath("html/head/title")
          yield node.text
        end

        uri = URI.parse(url)

        return if TITLE_ONLY_LIST.any?{|entry| uri.host == entry}

        if node = html.at_xpath('html/head/meta[@name="description"]')
          yield node[:content].lines.first(3).join
        end
      rescue => e
        error "#{e.class.name}: #{e.message}"
      end
    end
  end
end
