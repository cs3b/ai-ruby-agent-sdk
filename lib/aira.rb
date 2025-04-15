# frozen_string_literal: true

require_relative "aira/version"
require_relative "aira/logger"
require_relative "aira/errors"
require_relative "aira/dsl"
require_relative "aira/registry"
require_relative "aira/agent"
require_relative "aira/step"
require_relative "aira/file_queue"
require_relative "aira/tool_registry"
require_relative "aira/tool"
require_relative "aira/tools"
require_relative "aira/prompt"
require_relative "aira/tool_registry_adapter"

module Aira
  class Error < StandardError; end
  
  # Include the DSL methods directly in the Aira module
  def self.agent(name, &block)
    DSL.agent(name, &block)
  end
end
