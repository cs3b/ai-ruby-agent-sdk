# frozen_string_literal: true

require 'erb'
require 'logger'
require 'aira/errors'

module Aira
  # Agent class for defining and running AI agents
  class Agent
    attr_accessor :name, :description, :input, :output, :prompt, :tools, :steps,
                  :source_directory, :output_directory, :loop_block, :review_block

    # Initialize a new agent
    # @param name [Symbol, String] The name of the agent
    def initialize(name)
      @name = name.to_sym
      @description = nil
      @input = {}
      @output = {}
      @prompt = nil
      @tools = []
      @steps = []
      @source_directory = nil
      @output_directory = nil
      @loop_block = nil
      @review_block = nil
      @logger = Aira::Logger.for(:agent)
    end

    # Run the agent with the provided inputs
    # @param inputs [Hash] The input values for the agent
    # @return [Hash] The output values from the agent
    def run(inputs = {})
      @logger.info("Running agent #{name}...")
      context = inputs.dup

      begin
        # Validate required inputs
        validate_inputs(inputs)
        
        # Render the prompt if provided
        if prompt
          context[:_prompt] = render_prompt(context)
        end
        
        # Execute each step in sequence
        steps.each do |step|
          step.execute(context)
        end
        
        # Call the review block if provided
        if review_block
          review_block.call(context)
        end
        
        @logger.info("Agent #{name} completed successfully")
        context
      rescue StandardError => e
        @logger.error("Agent #{name} failed: #{e.message}")
        raise AgentError, "Agent #{name} failed: #{e.message}"
      end
    end

    # Add a step to the agent
    # @param step [Aira::Step] The step to add
    # @return [Aira::Step] The added step
    def add_step(step)
      @steps << step
      step
    end

    # Compare this agent with another agent
    # @param other [Object] The object to compare with
    # @return [Boolean] True if the agents are equal, false otherwise
    def ==(other)
      return false unless other.is_a?(Agent)
      
      name == other.name &&
        description == other.description &&
        input == other.input &&
        output == other.output &&
        prompt == other.prompt &&
        tools == other.tools
    end

    private

    # Render the prompt template with the provided context
    # @param context [Hash] The context for rendering the prompt
    # @return [String] The rendered prompt
    def render_prompt(context = {})
      begin
        ERB.new(prompt).result_with_hash(context)
      rescue StandardError => e
        @logger.error("Failed to render prompt: #{e.message}")
        raise PromptError, "Failed to render prompt: #{e.message}"
      end
    end

    # Validate that all required inputs are provided
    # @param inputs [Hash] The input values to validate
    # @raise [AgentError] If any required inputs are missing
    def validate_inputs(inputs)
      missing = []
      
      input.each do |name, options|
        if options.is_a?(Hash) && options[:required] && !inputs.key?(name)
          missing << name
        end
      end
      
      unless missing.empty?
        @logger.error("Missing required inputs: #{missing.join(', ')}")
        raise AgentError, "Missing required inputs: #{missing.join(', ')}"
      end
    end
  end
end
