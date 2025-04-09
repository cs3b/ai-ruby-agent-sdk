# frozen_string_literal: true

module Aira
  # A step in an agent's workflow
  class Step
    attr_accessor :name, :description, :tool, :block

    # Initialize a new step
    # @param name [Symbol] The name of the step
    # @param description [String] The description of the step
    # @param tool [Symbol] The tool to use for this step
    # @param block [Proc] The block to execute for this step
    def initialize(name, description: nil, tool: nil, &block)
      @name = name
      @description = description
      @tool = tool
      @block = block
      @logger = Aira::Logger.for(:step)
    end

    # Run the step with the given context
    # @param context [Hash] The context for the step
    # @return [Hash] The updated context after the step
    def run(context)
      @logger.info("Running step #{name}...")
      
      begin
        # If a tool is specified, add it to the context
        if tool && (tool_instance = ToolRegistryAdapter.get_tool(tool))
          @logger.debug("Using tool #{tool} for step #{name}")
          context[:_current_tool] = tool_instance
        end
        
        # Execute the block if provided
        if block
          @logger.debug("Executing block for step #{name}")
          block.call(context)
        else
          @logger.debug("No block provided for step #{name}")
        end
        
        @logger.info("Step #{name} completed successfully")
        context
      rescue StandardError => e
        @logger.error("Step #{name} failed: #{e.message}")
        raise StepError.new("Step #{name} failed: #{e.message}", 
          step: name, input: context, cause: e)
      end
    end
  end
end
