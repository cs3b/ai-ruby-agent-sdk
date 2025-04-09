# frozen_string_literal: true

require 'erb'
require 'ruby_llm'
require 'aira/logger'

module Aira
  # Core Agent class representing a defined agent
  class Agent
    attr_accessor :name, :description, :input, :output, :prompt, :tools, :steps, 
                  :loop_block, :review_block, :source_directory, :output_directory

    # Initialize a new agent
    # @param name [Symbol] The name of the agent
    def initialize(name)
      @name = name.to_sym
      @input = {}
      @output = {}
      @tools = []
      @steps = []
      @logger = Aira::Logger.for(:agent)
    end

    # Convert agent to a hash representation
    # @return [Hash] The agent as a hash
    def to_h
      {
        name: name,
        description: description,
        input: input,
        output: output,
        prompt: prompt,
        tools: tools,
        steps: steps,
        loop_block: loop_block,
        review_block: review_block,
        source_directory: source_directory,
        output_directory: output_directory
      }
    end

    # Render the prompt using ERB. Data is passed as a hash.
    # @param data [Hash] The data to interpolate into the prompt
    # @return [String] The rendered prompt
    def render_prompt(data = {})
      begin
        ERB.new(prompt).result_with_hash(data)
      rescue StandardError => e
        @logger.error("Failed to render prompt: #{e.message}")
        raise PromptError.new("Failed to render prompt: #{e.message}", 
          template: prompt, data: data, cause: e)
      end
    end

    # Get tool instances for this agent
    # @return [Array<Object>] The tool instances
    def tool_instances
      tools.map do |tool_name|
        begin
          ToolRegistryAdapter.get_tool(tool_name) || 
            raise("Tool not found: #{tool_name}")
        rescue StandardError => e
          @logger.error("Failed to get tool '#{tool_name}': #{e.message}")
          raise ToolError.new("Failed to get tool '#{tool_name}': #{e.message}", 
            tool_name: tool_name, cause: e)
        end
      end
    end

    # Run the agent with the given context
    # @param context [Hash] The context for the agent run
    # @return [Hash] The updated context after the agent run
    def run(context = {})
      @logger.info("Running agent #{name}...")
      
      begin
        # Validate required inputs
        validate_inputs(context)
        
        rendered_prompt = render_prompt(context)
        @logger.debug("Prompt: #{rendered_prompt}")
        
        # Here you'd normally call ruby-llm with the rendered prompt and tools
        # For example:
        # response = RubyLLM.chat(
        #   messages: [{ role: "user", content: rendered_prompt }],
        #   tools: tool_instances
        # )
        
        # For steps workflows, iterate over steps
        steps.each do |step|
          step.run(context)
        end

        # Run the loop block if defined
        loop(context) if loop_block

        # Run the review block if defined
        review_block.call(context) if review_block
        
        @logger.info("Agent #{name} completed successfully")
        context
      rescue StandardError => e
        @logger.error("Agent #{name} failed: #{e.message}")
        raise AgentError.new("Agent #{name} failed: #{e.message}", 
          agent: name, context: context, cause: e)
      end
    end

    # Run the loop block with the given context
    # @param context [Hash] The context for the loop
    def loop(context = {})
      @logger.debug("Running loop for agent #{name}...")
      instance_exec(context, &loop_block)
    end
    
    private
    
    # Validate that all required inputs are present in the context
    # @param context [Hash] The context to validate
    # @raise [AgentError] If a required input is missing
    def validate_inputs(context)
      missing_inputs = input.keys.select { |key| !context.key?(key) }
      
      if missing_inputs.any?
        error_msg = "Missing required inputs: #{missing_inputs.join(', ')}"
        @logger.error(error_msg)
        raise AgentError.new(error_msg, agent: name, context: context)
      end
    end
  end
end
