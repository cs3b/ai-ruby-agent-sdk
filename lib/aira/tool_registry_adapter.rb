# frozen_string_literal: true

module Aira
  # Adapter to connect Aira's tool registry with external tool registries
  class ToolRegistryAdapter
    class << self
      # Get a tool instance by name
      # @param name [Symbol] The name of the tool
      # @return [Object, nil] The tool instance or nil if not found
      def get_tool(name)
        tool_class = ToolRegistry.get(name)
        return nil unless tool_class
        
        # Return a new instance of the tool class
        tool_class.new
      end
      
      # Register all tools with RubyLLM
      # This method is a placeholder for future integration with RubyLLM
      def register_with_ruby_llm
        # This is a placeholder for future integration with RubyLLM
        # For now, we'll just log that we're registering tools
        Aira::Logger.for(:tool_registry).info("Registered #{ToolRegistry.tools.size} tools with Aira")
      end
    end
  end
end
