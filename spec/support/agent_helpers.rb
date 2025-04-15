# frozen_string_literal: true

module AgentHelpers
  # Create a test agent with basic configuration
  def create_test_agent(name = "test_agent")
    Aira.agent name do
      description "Test agent for unit tests"
      input :test_input
      output :test_output
      prompt "Test prompt"
      
      steps do
        step :test_step, description: "Test step" do |context|
          context[:test_output] = "Test output: #{context[:test_input]}"
        end
      end
    end
    
    Aira::Registry.get(name)
  end
end

RSpec.configure do |config|
  config.include AgentHelpers
end
