# frozen_string_literal: true

require "webmock/rspec"

RSpec.describe Aira::Tools::WeatherTool do
  let(:weather_tool) { Aira::Tools::WeatherTool.new }
  let(:latitude) { 52.52 }
  let(:longitude) { 13.41 }
  let(:api_url) { "https://api.open-meteo.com/v1/forecast" }
  
  before do
    WebMock.disable_net_connect!
  end
  
  after do
    WebMock.allow_net_connect!
  end
  
  describe "#description" do
    it "returns a description of the tool" do
      expect(weather_tool.description).to be_a(String)
      expect(weather_tool.description).not_to be_empty
    end
  end
  
  describe "#parameters" do
    it "defines the expected parameters" do
      params = weather_tool.parameters
      expect(params.keys).to include(:latitude, :longitude)
      
      # Check latitude parameter
      expect(params[:latitude].name).to eq(:latitude)
      expect(params[:latitude].type).to eq("number")
      expect(params[:latitude].required).to be true
      
      # Check longitude parameter
      expect(params[:longitude].name).to eq(:longitude)
      expect(params[:longitude].type).to eq("number")
      expect(params[:longitude].required).to be true
    end
  end
  
  describe "#call" do
    let(:mock_response) do
      {
        "latitude" => latitude,
        "longitude" => longitude,
        "timezone" => "Europe/Berlin",
        "current" => {
          "temperature_2m" => 15.3,
          "wind_speed_10m" => 7.2
        }
      }
    end
    
    before do
      # Stub the API request
      stub_request(:get, api_url)
        .with(
          query: hash_including(
            {
              "latitude" => latitude.to_s,
              "longitude" => longitude.to_s,
              "current" => "temperature_2m,wind_speed_10m"
            }
          )
        )
        .to_return(
          status: 200,
          body: mock_response.to_json,
          headers: { "Content-Type" => "application/json" }
        )
    end
    
    it "fetches weather data for the specified coordinates" do
      result = weather_tool.call(latitude: latitude, longitude: longitude)
      expect(result).to be_a(Hash)
      expect(result["latitude"]).to eq(latitude)
      expect(result["longitude"]).to eq(longitude)
      expect(result["current"]["temperature_2m"]).to eq(15.3)
      expect(result["current"]["wind_speed_10m"]).to eq(7.2)
    end
    
    it "raises an error when the API request fails" do
      # Stub a failed API request
      stub_request(:get, api_url)
        .with(
          query: hash_including(
            {
              "latitude" => "invalid",
              "longitude" => longitude.to_s,
              "current" => "temperature_2m,wind_speed_10m"
            }
          )
        )
        .to_return(
          status: 400,
          body: { "error" => true, "reason" => "Invalid latitude" }.to_json,
          headers: { "Content-Type" => "application/json" }
        )
      
      expect {
        weather_tool.call(latitude: "invalid", longitude: longitude)
      }.to raise_error(Aira::Error, /Failed to fetch weather data/)
    end
  end
end
