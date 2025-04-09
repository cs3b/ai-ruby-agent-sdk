# frozen_string_literal: true

require 'aira/errors'

module Aira
  # Registry to hold all defined agents
  module Registry
    @agents = {}

    class << self
      # Register an agent in the registry
      # @param name [Symbol, String] The name of the agent
      # @param agent [Aira::Agent] The agent to register
      # @return [Aira::Agent] The registered agent
      # @raise [Aira::Error] If the agent is nil
      def register(name, agent)
        raise Aira::Error, "Cannot register nil agent" if agent.nil?
        @agents[name.to_sym] = agent
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
      
      # Get the names of all registered agents
      # @return [Array<Symbol>] The names of all registered agents
      def available_agents
        @agents.keys
      end
    end
  end
end
