# -*- coding: utf-8 -*-
require 'cinch'
require "curb"
require 'json'
require "uri"

module Cinch::Plugins
  class Openweathermap
    include Cinch::Plugin

    match /weather (.*)/

    def execute(m, query)
      search(query) do |text|
        m.channel.notice text
      end
    end
    
    private
    def search(query)
      url = URI.encode "http://api.openweathermap.org/data/2.5/weather?q=#{query}"
      http = Curl.get(url)
      json = JSON.parse(http.body_str)
      if json["cod"].to_i == 200
        yield "#{json['name']} #{Time.at(json['dt'])}"
        yield " Temperature: #{to_celsius(json['main']['temp'])}"
        yield " Humidity   : #{json['main']['humidity']}%"
        yield " Weather    :"
        json["weather"].each do | weather |
          yield " - #{weather['main']}/#{weather['description']}"
        end
        rain = json["rain"]
        rain.each do |key, value|
          yield " Rain       : #{value}mm/#{key}"
        end
        # Forecast
        url = URI.encode "http://api.openweathermap.org/data/2.5/forecast?q=#{query}"
        http = Curl.get(url)
        json = JSON.parse(http.body_str)
        if json["cod"].to_i == 200
          yield " Forecast"
          json['list'].each_with_index do |f, i|
            break if i > 9
            weather = f["weather"][0]
            main = f['main']
            yield " - [%s] %-6s - %-20s %-5s / %-5s" % [
                               Time.at(f['dt']).strftime("%Y/%m/%d %H:%M"),
                               weather['main'],
                               weather['description'],
                               to_celsius(main['temp_max']),
                               to_celsius(main['temp_min'])
                              ]
          end
        else
          yield json["message"]
        end
      else
        yield json["message"]
      end
    end

    def to_celsius(kelvin)
      sprintf("%.2fC", kelvin - 273.15)
    end
  end
end
