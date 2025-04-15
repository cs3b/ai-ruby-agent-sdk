# frozen_string_literal: true

require 'faraday'
require 'json'

module Aira
  module Tools
    # Tool for fetching weather data from Open Meteo API
    class WeatherTool
      include Aira::Tool
      
      description "Gets current weather for a location"
      
      param :latitude, type: "number", desc: "Latitude (e.g., 52.5200)"
      param :longitude, type: "number", desc: "Longitude (e.g., 13.4050)"

      # Execute the weather tool with the given parameters
      # @param params [Hash] The parameters
      # @return [Hash] The weather data
      def call(params)
        latitude = params[:latitude]
        longitude = params[:longitude]
        
        url = "https://api.open-meteo.com/v1/forecast?latitude=#{latitude}&longitude=#{longitude}&current=temperature_2m,wind_speed_10m"
        response = Faraday.get(url)
        
        if response.status == 200
          JSON.parse(response.body)
        else
          error_message = "Failed to fetch weather data: #{response.status} #{response.body}"
          raise Aira::Error, error_message
        end
      rescue StandardError => e
        raise Aira::Error, "Failed to fetch weather data: #{e.message}"
      end
    end
  end
end
