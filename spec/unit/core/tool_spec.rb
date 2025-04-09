# frozen_string_literal: true

# Define a test tool class for our tests
class TestTool
  include Aira::Tool
  
  description "Test tool description"
  
  param :required_param,
        type: "string",
        desc: "Required parameter",
        required: true
        
  param :optional_param,
        type: "integer",
        desc: "Optional parameter",
        required: false
  
  def call(params)
    validate_parameters(params)
    "Called with #{params[:required_param]} and #{params[:optional_param]}"
  end
  
  def validate_parameters(params)
    self.class.parameters.each do |name, param|
      if param.required && !params.key?(name)
        raise Aira::Error, "Missing required parameter: #{name}"
      end
    end
  end
end

RSpec.describe Aira::Tool do
  let(:tool) { TestTool.new }
  
  describe ".description" do
    it "returns the tool description" do
      expect(TestTool.description).to eq("Test tool description")
    end
  end
  
  describe ".parameters" do
    it "returns the defined parameters" do
      params = TestTool.parameters
      expect(params.keys).to contain_exactly(:required_param, :optional_param)
      
      expect(params[:required_param].name).to eq(:required_param)
      expect(params[:required_param].type).to eq("string")
      expect(params[:required_param].description).to eq("Required parameter")
      expect(params[:required_param].required).to be true
      
      expect(params[:optional_param].name).to eq(:optional_param)
      expect(params[:optional_param].type).to eq("integer")
      expect(params[:optional_param].description).to eq("Optional parameter")
      expect(params[:optional_param].required).to be false
    end
  end
  
  describe "#call" do
    it "executes the tool with the provided parameters" do
      result = tool.call(required_param: "test", optional_param: 42)
      expect(result).to eq("Called with test and 42")
    end
    
    it "raises an error when a required parameter is missing" do
      expect {
        tool.call(optional_param: 42)
      }.to raise_error(Aira::Error, /Missing required parameter/)
    end
  end
  
  describe "#validate_parameters" do
    it "validates required parameters" do
      expect {
        tool.validate_parameters({})
      }.to raise_error(Aira::Error, /Missing required parameter/)
    end
    
    it "passes validation when all required parameters are provided" do
      expect {
        tool.validate_parameters(required_param: "test")
      }.not_to raise_error
    end
  end
end
