# frozen_string_literal: true

RSpec.describe Aira::Registry do
  # Create a simple agent for testing
  let(:agent_name) { :registry_test_agent }
  let(:agent) { create_test_agent(agent_name) }
  
  before do
    # Ensure the agent is registered
    Aira::Registry.register(agent_name, agent)
  end
  
  describe ".register" do
    it "registers an agent in the registry" do
      # Agent is registered in the before block
      expect(Aira::Registry.get(agent_name)).to eq(agent)
    end
    
    it "converts string names to symbols" do
      string_name_agent = create_test_agent("string_name_agent")
      Aira::Registry.register("string_name_agent", string_name_agent)
      expect(Aira::Registry.get(:string_name_agent)).to eq(string_name_agent)
    end
    
    it "raises an error when registering nil" do
      expect {
        Aira::Registry.register(:nil_agent, nil)
      }.to raise_error(Aira::Error, /Cannot register nil agent/)
    end
  end
  
  describe ".get" do
    it "retrieves a registered agent by name" do
      expect(Aira::Registry.get(agent_name)).to eq(agent)
    end
    
    it "returns nil for unregistered agents" do
      expect(Aira::Registry.get(:nonexistent_agent)).to be_nil
    end
    
    it "converts string names to symbols" do
      expect(Aira::Registry.get(agent_name.to_s)).to eq(agent)
    end
  end
  
  describe ".available_agents" do
    before do
      # Register a couple of agents for testing
      agent1 = create_test_agent(:agent1)
      agent2 = create_test_agent(:agent2)
      Aira::Registry.register(:agent1, agent1)
      Aira::Registry.register(:agent2, agent2)
    end
    
    it "returns the names of all registered agents" do
      available_agents = Aira::Registry.available_agents
      expect(available_agents).to include(:agent1)
      expect(available_agents).to include(:agent2)
    end
  end
end
