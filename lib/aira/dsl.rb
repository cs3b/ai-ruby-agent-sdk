# frozen_string_literal: true

require_relative 'agent'
require_relative 'step'
require_relative 'registry'

module Aira
  # DSL Builder to allow clean agent definitions
  module DSL
    # Define a new agent
    # @param name [Symbol, String] The name of the agent
    # @param block [Proc] The block containing the agent definition
    # @return [Aira::Agent] The created agent
    def agent(name, &block)
      builder = AgentBuilder.new(name)
      builder.instance_eval(&block)
      Registry.register(builder.build)
    end
  end

  # The builder object for an agent
  class AgentBuilder
    # Initialize a new agent builder
    # @param name [Symbol, String] The name of the agent
    def initialize(name)
      @agent = Agent.new(name)
    end

    # Set the agent description
    # @param text [String] The description text
    def description(text)
      @agent.description = text
    end

    # Define an input parameter for the agent
    # @param name [Symbol, String] The name of the input parameter
    # @param type [Symbol] The type of the input parameter
    def input(name, type: :string)
      @agent.input[name.to_sym] = type
    end

    # Define an output parameter for the agent
    # @param name [Symbol, String] The name of the output parameter
    # @param type [Symbol] The type of the output parameter
    def output(name, type: :string)
      @agent.output[name.to_sym] = type
    end

    # Set the prompt template for the agent
    # @param text [String, nil] The prompt text
    # @param block [Proc, nil] A block that returns the prompt text
    def prompt(text = nil, &block)
      if block_given?
        @agent.prompt = block.call
      elsif text
        @agent.prompt = text
      end
    end

    # Define the tools the agent can use
    # @param tools [Array<Symbol>] The tools to use
    def tools(*tools)
      @agent.tools.concat(tools)
    end

    # Define steps for the agent
    # @param block [Proc] The block containing step definitions
    def steps(&block)
      instance_eval(&block)
    end

    # Define a step in an agent's workflow
    # @param name [Symbol] The name of the step
    # @param description [String] The description of the step
    # @param tool [Symbol] The tool to use for this step
    # @param block [Proc] The block to execute for this step
    # @return [Step] The created step
    def step(name, description: nil, tool: nil, &block)
      step = Step.new(name, description: description, tool: tool, &block)
      @agent.steps << step
      step
    end

    # Define a loop block to keep checking until work is done
    # @param block [Proc] The loop block
    def loop(&block)
      @agent.loop_block = block
    end

    # Define a review block to validate the output
    # @param block [Proc] The review block
    def review(&block)
      @agent.review_block = block
    end

    # Set the source directory for the agent
    # @param path [String] The source directory path
    def source_directory(path)
      @agent.source_directory = path
    end

    # Set the output directory for the agent
    # @param path [String] The output directory path
    def output_directory(path)
      @agent.output_directory = path
    end

    # Build and return the agent
    # @return [Aira::Agent] The built agent
    def build
      @agent
    end
  end
end
