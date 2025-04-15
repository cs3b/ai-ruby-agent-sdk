# frozen_string_literal: true

module Aira
  # Unified interface for all external tools
  module ToolRegistry
    @tools = {}

    class << self
      # Register a tool in the registry
      # @param name [Symbol, String] The name of the tool
      # @param tool [Object] The tool implementation
      # @return [Object] The registered tool
      def register(name, tool)
        @tools[name.to_sym] = tool
      end

      # Get a tool by name
      # @param name [Symbol, String] The name of the tool
      # @return [Object, nil] The tool or nil if not found
      def get(name)
        @tools[name.to_sym]
      end

      # Get all available tools
      # @return [Array<Symbol>] Names of all available tools
      def available_tools
        @tools.keys
      end
      
      # Get all registered tools
      # @return [Hash] A hash of tool names to tool implementations
      def tools
        @tools
      end
    end
  end
end
