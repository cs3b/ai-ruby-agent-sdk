# frozen_string_literal: true

# Define a test tool class for our tests
class TestRegistryTool
  include Aira::Tool
  
  description "Test registry tool"
  
  param :param, type: "string", desc: "Test parameter", required: true
  
  def call(params)
    "Test registry tool called with: #{params[:param]}"
  end
end

RSpec.describe Aira::ToolRegistry do
  describe ".register" do
    it "registers a tool in the registry" do
      Aira::ToolRegistry.register(:test_registry_tool, TestRegistryTool)
      expect(Aira::ToolRegistry.get(:test_registry_tool)).to eq(TestRegistryTool)
    end
    
    it "converts string names to symbols" do
      Aira::ToolRegistry.register("string_name_tool", TestRegistryTool)
      expect(Aira::ToolRegistry.get(:string_name_tool)).to eq(TestRegistryTool)
    end
  end
  
  describe ".get" do
    before do
      Aira::ToolRegistry.register(:get_test_tool, TestRegistryTool)
    end
    
    it "retrieves a registered tool by name" do
      expect(Aira::ToolRegistry.get(:get_test_tool)).to eq(TestRegistryTool)
    end
    
    it "returns nil for unregistered tools" do
      expect(Aira::ToolRegistry.get(:nonexistent_tool)).to be_nil
    end
    
    it "converts string names to symbols" do
      expect(Aira::ToolRegistry.get("get_test_tool")).to eq(TestRegistryTool)
    end
  end
  
  describe ".available_tools" do
    before do
      # Register a couple of tools for testing
      Aira::ToolRegistry.register(:tool1, TestRegistryTool)
      Aira::ToolRegistry.register(:tool2, TestRegistryTool)
    end
    
    it "returns the names of all registered tools" do
      available_tools = Aira::ToolRegistry.available_tools
      expect(available_tools).to include(:tool1)
      expect(available_tools).to include(:tool2)
    end
  end
  
  describe ".tools" do
    before do
      Aira::ToolRegistry.register(:tools_test_tool, TestRegistryTool)
    end
    
    it "returns a hash of all registered tools" do
      tools = Aira::ToolRegistry.tools
      expect(tools).to be_a(Hash)
      expect(tools[:tools_test_tool]).to eq(TestRegistryTool)
    end
  end
end
