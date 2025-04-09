# frozen_string_literal: true

module ToolHelpers
  # Create a test tool for unit tests
  class TestTool
    include Aira::Tool
    
    class << self
      def description
        "Test tool for unit tests"
      end
      
      def parameters
        {
          test_param: Aira::Tool::Parameter.new(
            :test_param,
            type: "string",
            desc: "Test parameter",
            required: true
          )
        }
      end
    end
    
    def call(params)
      "Test tool called with: #{params[:test_param]}"
    end
  end
  
  # Register test tools
  def register_test_tools
    Aira::ToolRegistry.register(:test_tool, TestTool)
  end
  
  # Clean up test tools
  def clean_test_tools
    # This is a mock implementation since we can't directly remove tools from the registry
    # In a real implementation, we might want to reset the registry or use a different approach
  end
end

RSpec.configure do |config|
  config.include ToolHelpers
  
  config.before(:each) do
    register_test_tools
  end
  
  config.after(:each) do
    clean_test_tools
  end
end
