# frozen_string_literal: true

module Aira
  module Tools
    # Register all tools with the ToolRegistry
    module Registry
      # Register all tools
      # @return [void]
      def self.register_all
        # Register the file tool
        Aira::ToolRegistry.register(:file_tool, Aira::Tools::FileTool)
        
        # Register the weather tool
        Aira::ToolRegistry.register(:weather_tool, Aira::Tools::WeatherTool)
      end
    end
  end
end
