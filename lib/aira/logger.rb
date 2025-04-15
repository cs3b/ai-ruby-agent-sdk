# frozen_string_literal: true

require 'logger'

module Aira
  # Logging system for Aira
  module Logger
    @loggers = {}
    @default_level = ::Logger::INFO
    
    class << self
      # Get the logger for a specific component
      # @param component [String, Symbol] The component name
      # @return [::Logger] The logger instance
      def for(component)
        component_name = component.to_s
        @loggers[component_name] ||= create_logger(component_name)
      end
      
      # Set the log level for all loggers
      # @param level [Integer] The log level (use ::Logger constants)
      def level=(level)
        @default_level = level
        @loggers.each_value { |logger| logger.level = level }
      end
      
      # Get the current log level
      # @return [Integer] The current log level
      def level
        @default_level
      end
      
      private
      
      # Create a new logger instance
      # @param component [String] The component name
      # @return [::Logger] The new logger instance
      def create_logger(component)
        logger = ::Logger.new($stdout)
        logger.level = @default_level
        logger.progname = "aira:#{component}"
        logger.formatter = proc do |severity, datetime, progname, msg|
          "[#{datetime.strftime('%Y-%m-%d %H:%M:%S')}] #{severity} #{progname}: #{msg}\n"
        end
        logger
      end
    end
  end
end
