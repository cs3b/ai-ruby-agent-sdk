# frozen_string_literal: true

module Aira
  # Registry to hold all defined agents
  module Registry
    @agents = {}

    class << self
      # Register an agent in the registry
      # @param agent [Aira::Agent] The agent to register
      # @return [Aira::Agent] The registered agent
      def register(agent)
        @agents[agent.name] = agent
      end

      # Get an agent by name
      # @param name [Symbol, String] The name of the agent
      # @return [Aira::Agent, nil] The agent or nil if not found
      def get(name)
        @agents[name.to_sym]
      end

      # Get all registered agents
      # @return [Array<Aira::Agent>] All registered agents
      def all
        @agents.values
      end
    end
  end
end
