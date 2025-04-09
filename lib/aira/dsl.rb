# frozen_string_literal: true

require 'aira/agent'
require 'aira/registry'
require 'aira/step'

module Aira
  # DSL for defining agents
  module DSL
    # Define an agent
    # @param name [Symbol, String] The name of the agent
    # @param block [Proc] The block defining the agent
    # @return [Aira::Agent] The defined agent
    def self.agent(name, &block)
      agent = Agent.new(name)
      builder = AgentBuilder.new(agent)
      builder.instance_eval(&block)
      
      Registry.register(name, agent)
      agent
    end
    
    def agent(name, &block)
      self.class.extend(DSL) unless self.class.respond_to?(:agent)
      DSL.agent(name, &block)
    end
    
    # Builder class for agents
    class AgentBuilder
      # Initialize a new agent builder
      # @param agent [Aira::Agent] The agent to build
      def initialize(agent)
        @agent = agent
      end
      
      # Set the description for the agent
      # @param text [String] The description text
      def description(text)
        @agent.description = text
      end
      
      # Define an input parameter for the agent
      # @param name [Symbol, String] The name of the input parameter
      # @param type [Symbol] The type of the input parameter
      # @param required [Boolean] Whether the input is required
      def input(name, type: :string, required: true)
        @agent.input[name.to_sym] = { type: type, required: required }
      end
      
      # Define an output parameter for the agent
      # @param name [Symbol, String] The name of the output parameter
      # @param type [Symbol] The type of the output parameter
      def output(name, type: :string)
        @agent.output[name.to_sym] = type
      end
      
      # Define the prompt template for the agent
      # @param template [String] The prompt template
      def prompt(template)
        @agent.prompt = template
      end
      
      # Define the tools for the agent
      # @param tool_names [Array<Symbol>] The names of the tools
      def tools(*tool_names)
        @agent.tools = tool_names.map(&:to_sym)
      end
      
      # Define the source directory for the agent
      # @param path [String] The source directory path
      def source_directory(path)
        @agent.source_directory = path
      end
      
      # Define the output directory for the agent
      # @param path [String] The output directory path
      def output_directory(path)
        @agent.output_directory = path
      end
      
      # Define the steps for the agent
      # @param block [Proc] The block defining the steps
      def steps(&block)
        builder = StepsBuilder.new(@agent)
        builder.instance_eval(&block)
      end
      
      # Define the review block for the agent
      # @param block [Proc] The review block
      def review(&block)
        @agent.review_block = block
      end
      
      # Define the loop block for the agent
      # @param block [Proc] The loop block
      def loop(&block)
        @agent.loop_block = block
      end
    end
    
    # Builder class for steps
    class StepsBuilder
      # Initialize a new steps builder
      # @param agent [Aira::Agent] The agent to build steps for
      def initialize(agent)
        @agent = agent
      end
      
      # Define a step for the agent
      # @param name [Symbol, String] The name of the step
      # @param tool [Symbol, nil] The tool to use for the step
      # @param description [String, nil] The description of the step
      # @param block [Proc] The block defining the step
      # @return [Aira::Step] The defined step
      def step(name, tool: nil, description: nil, &block)
        step = Step.new(name, tool: tool, description: description, &block)
        @agent.add_step(step)
      end
    end
  end
end
