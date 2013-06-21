require 'cinch'
require "curb"
require 'nokogiri'
require "uri"

module Cinch::Plugins

  class Urbandictionary
    include Cinch::Plugin

    match /urban (.*)/
    def execute(m, query)
      search(query) do |text|
        m.channel.notice text
        m.channel.notice "-" * 50
      end
    end

    private
    def search(query)
      url = URI.encode "http://www.urbandictionary.com/define.php?term=#{query}"
      http = Curl.get(url)
      html = Nokogiri::HTML(http.body_str)
      
      html.css('.definition').first(3).each_with_index do |node, i|
        yield(node.text.strip)
      end
    rescue => e
      e.message
    end
  end
end
