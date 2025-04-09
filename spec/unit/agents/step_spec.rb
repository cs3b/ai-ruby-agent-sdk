# frozen_string_literal: true

RSpec.describe Aira::Step do
  let(:step_name) { :test_step }
  let(:step_description) { "Test step description" }
  let(:step_block) { ->(context) { context[:output] = "Processed: #{context[:input]}" } }
  
  let(:step) { Aira::Step.new(step_name, description: step_description, &step_block) }
  
  describe "#initialize" do
    it "creates a step with the specified name" do
      expect(step.name).to eq(step_name)
    end
    
    it "sets the description" do
      expect(step.description).to eq(step_description)
    end
    
    it "stores the execution block" do
      expect(step.instance_variable_get(:@block)).to eq(step_block)
    end
    
    it "initializes with a tool if provided" do
      tool_step = Aira::Step.new(:tool_step, tool: :test_tool, description: "Tool step")
      expect(tool_step.tool).to eq(:test_tool)
    end
  end
  
  describe "#execute" do
    let(:context) { { input: "test input" } }
    let(:logger) { instance_double(Logger) }
    
    before do
      allow(Aira::Logger).to receive(:for).and_return(logger)
      allow(logger).to receive(:info)
      allow(logger).to receive(:debug)
      allow(logger).to receive(:error)
    end
    
    it "executes the step block with the provided context" do
      step.execute(context)
      expect(context[:output]).to eq("Processed: test input")
    end
    
    it "logs step execution" do
      expect(logger).to receive(:info).with(/Running step/)
      expect(logger).to receive(:info).with(/Step .* completed successfully/)
      
      step.execute(context)
    end
    
    it "handles errors during execution" do
      error_step = Aira::Step.new(:error_step) do |_context|
        raise StandardError, "Test error"
      end
      
      expect(logger).to receive(:error).with(/Step .* failed/)
      
      expect {
        error_step.execute(context)
      }.to raise_error(Aira::StepError, /Step .* failed/)
    end
    
    context "with a tool" do
      let(:test_tool) { ToolHelpers::TestTool.new }
      
      before do
        allow(Aira::ToolRegistry).to receive(:get).with(:test_tool).and_return(test_tool)
      end
      
      it "executes the tool if specified" do
        tool_step = Aira::Step.new(:tool_step, tool: :test_tool) do |ctx|
          ctx[:tool_result] = ctx[:_tool_result]
        end
        
        expect(Aira::ToolRegistry).to receive(:get).with(:test_tool).and_return(test_tool)
        
        tool_step.execute(context)
        expect(context[:_tool_result]).to include("Test tool called with")
      end
      
      it "passes parameters to the tool" do
        tool_step = Aira::Step.new(:tool_step, tool: :test_tool) do |ctx|
          ctx[:tool_result] = ctx[:_tool_result]
        end
        
        context[:test_param] = "test value"
        
        tool_step.execute(context)
        expect(context[:_tool_result]).to include("test value")
      end
    end
  end
end
