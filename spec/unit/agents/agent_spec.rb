# frozen_string_literal: true

RSpec.describe Aira::Agent do
  let(:agent_name) { :test_agent }
  let(:agent) { create_test_agent(agent_name) }
  let(:logger) { instance_double(Logger) }
  
  before do
    allow(Aira::Logger).to receive(:for).and_return(logger)
    allow(logger).to receive(:info)
    allow(logger).to receive(:debug)
    allow(logger).to receive(:error)
  end
  
  describe "#initialize" do
    it "creates an agent with the specified name" do
      expect(agent.name).to eq(agent_name)
    end
    
    it "sets the description" do
      expect(agent.description).to eq("Test agent for unit tests")
    end
  end
  
  describe "#run" do
    it "executes the agent with the provided inputs" do
      result = agent.run(test_input: "hello")
      expect(result).to be_a(Hash)
      expect(result[:test_output]).to eq("Test output: hello")
    end
    
    it "validates required inputs" do
      # Modify our agent to have a required input
      Aira.agent :required_input_agent do
        description "Agent with required input"
        input :required_input, required: true
        output :test_output
        
        steps do
          step :test_step do |context|
            context[:test_output] = "Got: #{context[:required_input]}"
          end
        end
      end
      
      # Should raise an error when required input is missing
      expect {
        Aira::Registry.get(:required_input_agent).run({})
      }.to raise_error(Aira::AgentError, /Missing required inputs/)
      
      # Should work when required input is provided
      result = Aira::Registry.get(:required_input_agent).run(required_input: "value")
      expect(result[:test_output]).to eq("Got: value")
    end
    
    it "logs agent execution" do
      expect(logger).to receive(:info).with(/Running agent/)
      expect(logger).to receive(:info).with(/Agent .* completed successfully/)
      
      agent.run(test_input: "hello")
    end
    
    it "handles errors during execution" do
      # Create an agent that raises an error
      Aira.agent :error_agent do
        description "Agent that raises an error"
        
        steps do
          step :error_step do
            raise StandardError, "Test error"
          end
        end
      end
      
      expect(logger).to receive(:error).with(/Agent .* failed/)
      
      expect {
        Aira::Registry.get(:error_agent).run({})
      }.to raise_error(Aira::AgentError, /Agent .* failed/)
    end
  end
  
  describe "#steps" do
    it "returns the agent's steps" do
      expect(agent.steps).to be_an(Array)
      expect(agent.steps.first).to be_a(Aira::Step)
    end
  end
  
  describe "#add_step" do
    it "adds a step to the agent" do
      new_step = Aira::Step.new(:new_step) do |context|
        context[:new_output] = "New step output"
      end
      
      agent.add_step(new_step)
      
      expect(agent.steps).to include(new_step)
      
      result = agent.run(test_input: "hello")
      expect(result[:new_output]).to eq("New step output")
    end
  end
end
