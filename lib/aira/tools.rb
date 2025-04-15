# frozen_string_literal: true

require_relative 'tools/file_tool'
require_relative 'tools/weather_tool'
require_relative 'tools/registry'

module Aira
  # Namespace for all tools
  module Tools
    # Register all tools with the ToolRegistry
    Tools::Registry.register_all
  end
end
