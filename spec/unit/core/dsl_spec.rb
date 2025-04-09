# frozen_string_literal: true

# Create a test class that extends the DSL module
class TestDSL
  extend Aira::DSL
end

RSpec.describe Aira::DSL do
  describe ".agent" do
    it "creates and registers an agent" do
      # Create an agent using the DSL
      TestDSL.agent :dsl_test_agent do
        description "DSL test agent"
        input :test_input
        output :test_output
        
        steps do
          step :test_step do |context|
            context[:test_output] = "DSL output: #{context[:test_input]}"
          end
        end
      end
      
      # Verify the agent was registered
      agent = Aira::Registry.get(:dsl_test_agent)
      expect(agent).not_to be_nil
      expect(agent.name).to eq(:dsl_test_agent)
      expect(agent.description).to eq("DSL test agent")
      
      # Verify the agent works
      result = agent.run(test_input: "hello from DSL")
      expect(result[:test_output]).to eq("DSL output: hello from DSL")
    end
    
    it "allows defining tools for the agent" do
      TestDSL.agent :tool_agent do
        description "Agent with tools"
        tools :test_tool
        
        steps do
          step :tool_step, tool: :test_tool do |context|
            context[:tool_result] = context[:_tool_result]
          end
        end
      end
      
      agent = Aira::Registry.get(:tool_agent)
      expect(agent.tools).to include(:test_tool)
    end
    
    it "allows defining source and output directories" do
      TestDSL.agent :directory_agent do
        description "Agent with directories"
        source_directory "source/path"
        output_directory "output/path"
      end
      
      agent = Aira::Registry.get(:directory_agent)
      expect(agent.source_directory).to eq("source/path")
      expect(agent.output_directory).to eq("output/path")
    end
    
    it "allows defining a prompt" do
      TestDSL.agent :prompt_agent do
        description "Agent with prompt"
        prompt "Test prompt template"
      end
      
      agent = Aira::Registry.get(:prompt_agent)
      expect(agent.prompt).to eq("Test prompt template")
    end
    
    it "allows defining a review block" do
      review_block = proc { |context| raise "Review failed" if context[:output].nil? }
      
      TestDSL.agent :review_agent do
        description "Agent with review"
        output :output
        
        steps do
          step :generate do |context|
            context[:output] = "Generated output"
          end
        end
        
        review(&review_block)
      end
      
      agent = Aira::Registry.get(:review_agent)
      expect(agent.review_block).to eq(review_block)
    end
  end
end
