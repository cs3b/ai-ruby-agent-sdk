# frozen_string_literal: true

# Add the lib directory to the load path for local development
$LOAD_PATH.unshift(File.expand_path('../lib', __dir__))
require 'aira'

# Define a weather agent
Aira.agent :weather_reporter do
  description "Get weather information for a location and generate a report"
  
  # Define input and output
  input :latitude
  input :longitude
  output :weather_report
  
  # Define a simple prompt - we'll generate the actual report in the steps
  prompt <<~PROMPT
    Generate a weather report for the given location.
  PROMPT
  
  # Specify the tools this agent can use
  tools :weather_tool
  
  # Define the source and output directories
  source_directory 'jobs/weather'
  output_directory 'results/weather'
  
  # Define a multi-step workflow
  steps do
    step :fetch_weather, tool: :weather_tool, description: "Fetch weather data for the specified coordinates" do |context|
      # Use the tool directly from the context
      tool = context[:_current_tool]
      context[:weather_data] = tool.call(
        latitude: context[:latitude],
        longitude: context[:longitude]
      )
    end
    
    step :generate_report, description: "Generate a weather report based on the fetched data" do |context|
      # In a real implementation, this would use an LLM call with RubyLLM
      # For example:
      # response = RubyLLM.chat(
      #   messages: [
      #     { 
      #       role: "user", 
      #       content: "Create a weather report for temperature #{context[:weather_data]["current"]["temperature_2m"]}°C and wind speed #{context[:weather_data]["current"]["wind_speed_10m"]} km/h"
      #     }
      #   ]
      # )
      # context[:weather_report] = response.content
      
      # For demonstration purposes, we'll create a simple report
      context[:weather_report] = <<~REPORT
        # Weather Report
        
        ## Current Conditions
        
        **Location**: #{context[:latitude]}, #{context[:longitude]}
        
        **Temperature**: #{context[:weather_data]["current"]["temperature_2m"]}°C
        
        **Wind Speed**: #{context[:weather_data]["current"]["wind_speed_10m"]} km/h
        
        Have a great day!
      REPORT
    end
  end
  
  # Define a review block to validate the output
  review do |context|
    if context[:weather_report].nil? || context[:weather_report].empty?
      raise Aira::Error, "Weather report is empty or nil"
    end
    
    if context[:weather_report].lines.count < 5
      raise Aira::Error, "Weather report is too short"
    end
  end
end

# Run the agent with sample coordinates
if __FILE__ == $PROGRAM_NAME
  # Set log level to info for clearer output
  Aira::Logger.level = ::Logger::INFO
  
  begin
    puts "Running weather reporter agent..."
    agent = Aira::Registry.get(:weather_reporter)
    
    # Berlin coordinates
    result = agent.run(latitude: 52.5200, longitude: 13.4050)
    
    puts "\nGenerated Weather Report:"
    puts "------------------------"
    puts result[:weather_report]
  rescue Aira::Error => e
    puts "Error: #{e.message}"
    if e.respond_to?(:details) && e.details[:cause]
      puts "Caused by: #{e.details[:cause].message}"
    end
    exit 1
  end
end
