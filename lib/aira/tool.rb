# frozen_string_literal: true

require 'ruby_llm'

module Aira
  # Parameter definition for Tool methods
  class Parameter
    attr_reader :name, :type, :description, :required

    def initialize(name, type: 'string', desc: nil, required: true)
      @name = name
      @type = type
      @description = desc
      @required = required
    end
  end

  # Base module for creating tools that AI agents can use
  # Provides a simple interface for defining parameters and implementing tool behavior
  module Tool
    def self.included(base)
      base.extend(ClassMethods)
    end

    # Class methods to be extended by the including class
    module ClassMethods
      # Set the tool description
      # @param text [String, nil] The tool description
      # @return [String, nil] The tool description if no text provided
      def description(text = nil)
        return @description unless text

        @description = text
      end

      # Define a parameter for the tool
      # @param name [Symbol] The parameter name
      # @param options [Hash] The parameter options
      # @option options [String] :type The parameter type
      # @option options [String] :desc The parameter description
      # @option options [Boolean] :required Whether the parameter is required
      def param(name, **options)
        parameters[name] = Parameter.new(name, **options)
      end

      # Get the tool parameters
      # @return [Hash] The tool parameters
      def parameters
        @parameters ||= {}
      end
    end

    # Get the tool name
    # @return [String] The tool name
    def name
      self.class.name
          .to_s
          .split('::')
          .last
          .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
          .gsub(/([a-z\d])([A-Z])/, '\1_\2')
          .downcase
          .delete_suffix('_tool')
    end

    # Get the tool description
    # @return [String] The tool description
    def description
      self.class.description
    end

    # Get the tool parameters
    # @return [Hash] The tool parameters
    def parameters
      self.class.parameters
    end

    # Call the tool with the given arguments
    # @param args [Hash] The arguments to call the tool with
    # @return [Object] The result of the tool execution
    def call(args)
      Aira::Logger.for(:tool).debug "Tool #{name} called with: #{args.inspect}"
      result = execute(**args.transform_keys(&:to_sym))
      Aira::Logger.for(:tool).debug "Tool #{name} returned: #{result.inspect}"
      result
    end

    # Execute the tool with the given parameters
    # This method should be overridden by the including class
    # @param params [Hash] The parameters to execute the tool with
    # @return [Hash] The result of the execution
    def execute(...)
      raise NotImplementedError, "Tool must implement #execute"
    end
  end
end
