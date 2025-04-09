# frozen_string_literal: true

module Aira
  # Base error class for all Aira errors
  class Error < StandardError
    # Initialize a new error
    # @param message [String] The error message
    # @param details [Hash] Additional error details
    def initialize(message = nil, details = {})
      @details = details
      super(message)
    end
    
    # Get the error details
    # @return [Hash] The error details
    attr_reader :details
  end
  
  # Error raised when an agent encounters a problem
  class AgentError < Error; end
  
  # Error raised when a prompt has issues
  class PromptError < AgentError; end
  
  # Error raised when a tool encounters a problem
  class ToolError < AgentError; end
  
  # Error raised when a step encounters a problem
  class StepError < AgentError
    # Initialize a new step error
    # @param message [String] The error message
    # @param step [Symbol] The step name
    # @param input [Hash] The step input
    # @param cause [Exception] The underlying cause
    def initialize(message = nil, step: nil, input: nil, cause: nil)
      details = {
        step: step,
        input: input,
        cause: cause
      }
      super(message, details)
    end
    
    # Get the step name
    # @return [Symbol] The step name
    def step
      details[:step]
    end
    
    # Get the step input
    # @return [Hash] The step input
    def input
      details[:input]
    end
    
    # Get the underlying cause
    # @return [Exception] The underlying cause
    def cause
      details[:cause]
    end
  end
  
  # Error raised when a file queue encounters a problem
  class FileQueueError < Error; end
  
  # Error raised when a configuration is invalid
  class ConfigurationError < Error; end
end
