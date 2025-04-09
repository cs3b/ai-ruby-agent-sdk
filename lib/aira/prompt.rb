# frozen_string_literal: true

require 'erb'

module Aira
  # Handles template rendering and LLM interaction
  class PromptEngine
    attr_reader :template

    # Initialize a new prompt engine
    # @param template [String] The ERB template
    def initialize(template)
      @template = template
    end

    # Render the template with the given context
    # @param context [Hash] The context for rendering
    # @return [String] The rendered prompt
    def render(context = {})
      ERB.new(template).result_with_hash(context)
    end

    # Send the rendered prompt to an LLM
    # @param rendered_prompt [String] The rendered prompt
    # @param options [Hash] Options for the LLM call
    # @return [String] The LLM response
    def send_to_llm(rendered_prompt, options = {})
      # This is a placeholder for actual LLM integration
      # In a real implementation, you would use ruby-llm or another LLM client
      puts "Sending to LLM: #{rendered_prompt}"
      puts "Options: #{options}"
      
      # Simulate an LLM response
      "This is a simulated LLM response for: #{rendered_prompt.split.first(5).join(' ')}..."
    end
  end
end
