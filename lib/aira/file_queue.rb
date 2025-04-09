# frozen_string_literal: true

require 'fileutils'
require 'json'

module Aira
  # Handles file-based communication between agents
  module FileQueue
    # Directory-based queue implementation
    class Directory
      attr_reader :path, :pattern

      # Initialize a new directory queue
      # @param path [String] The directory path
      # @param pattern [String] The file pattern to match
      def initialize(path, pattern: '*')
        @path = path
        @pattern = pattern
        FileUtils.mkdir_p(path) unless Dir.exist?(path)
      end

      # Watch the directory for new files
      # @param block [Proc] The block to execute when a new file is found
      def watch(&block)
        loop do
          files = Dir.glob(File.join(path, pattern))
          files.each do |file|
            data = read_file(file)
            block.call(data, file) if block_given? && data
          end
          sleep 1
        end
      end

      # Enqueue data to the directory
      # @param data [Hash, String] The data to enqueue
      # @param filename [String, nil] The filename to use
      # @return [String] The path to the created file
      def enqueue(data, filename = nil)
        filename ||= "#{Time.now.to_i}_#{rand(1000)}.json"
        file_path = File.join(path, filename)
        
        content = data.is_a?(Hash) ? JSON.pretty_generate(data) : data.to_s
        File.write(file_path, content)
        
        file_path
      end

      # Dequeue a file from the directory
      # @return [Hash, nil] The data from the file or nil if no files
      def dequeue
        files = Dir.glob(File.join(path, pattern)).sort
        return nil if files.empty?
        
        file = files.first
        data = read_file(file)
        FileUtils.rm(file) if data
        
        data
      end

      private

      # Read data from a file
      # @param file [String] The file path
      # @return [Hash, String, nil] The data from the file or nil if error
      def read_file(file)
        content = File.read(file)
        
        # Try to parse as JSON, otherwise return as string
        begin
          JSON.parse(content, symbolize_names: true)
        rescue JSON::ParserError
          content
        end
      rescue StandardError => e
        puts "Error reading file #{file}: #{e.message}"
        nil
      end
    end
  end
end
