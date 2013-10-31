require 'cinch'
require "curb"
require 'nokogiri'
require "uri"
require "mechanize"
require "charlock_holmes"

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
        c = Curl::Easy.new(url) do |curl|
          curl.headers["User-Agent"] = Mechanize::AGENT_ALIASES['Mac Safari']
          curl.verbose = false
          curl.follow_location = true
        end
        c.perform
        str = c.body_str.to_s
        encode = CharlockHolmes::EncodingDetector.detect(str)[:encoding]
        str = str.encode("UTF-8", encode, :invalid => :replace, :undef=>:replace)

        html = Nokogiri::HTML(str)
        if node = html.at_xpath("html/head/title")
          title = node.text
          encode = CharlockHolmes::EncodingDetector.detect(title)[:encoding]
          title = encode == 'UTF-8' ?  title : title.encode("UTF-8", encode, :invalid => :replace, :undef=>:replace)
          yield title
        else
          return
        end

        uri = URI.parse(url)

        return if TITLE_ONLY_LIST.any?{|entry| uri.host == entry}

        if node = html.at_xpath('html/head/meta[@name="description"]')
          description = node[:content]
          # description = node[:content].lines.first(3).join
          description = encode == 'UTF-8' ?  description : description.encode("UTF-8", encode, :invalid => :replace, :undef=>:replace)
          yield description[0,140]
        end
      rescue => e
        error "#{e.class.name}: #{e.message}"
      end
    end
  end
end
