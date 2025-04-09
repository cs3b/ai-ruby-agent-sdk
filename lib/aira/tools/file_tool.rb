# frozen_string_literal: true

require 'fileutils'

module Aira
  module Tools
    # Tool for file operations (read, write, list)
    class FileTool
      include Aira::Tool
      
      description "Perform file operations such as reading, writing, and listing files"
      
      param :path, desc: "Path to the file or directory"
      param :content, desc: "Content to write to a file (for write operations)", required: false
      param :operation, desc: "Operation to perform (read, write, or list)"

      # Execute the file tool with the given parameters
      # @param path [String] The file or directory path
      # @param operation [String] The operation to perform (read, write, or list)
      # @param content [String, nil] The content to write (for write operations)
      # @return [Hash] The result of the operation
      def execute(path:, operation:, content: nil)
        case operation.to_s.downcase
        when 'read'
          read_file(path)
        when 'write'
          raise ArgumentError, "Content is required for write operations" unless content
          write_file(path, content)
        when 'list'
          list_files(path)
        else
          { error: "Unknown operation: #{operation}. Must be one of: read, write, list" }
        end
      end

      private

      # Read a file
      # @param path [String] The file path
      # @return [Hash] The file content
      def read_file(path)
        content = File.read(path)
        { content: content, path: path }
      rescue StandardError => e
        { error: "Failed to read file: #{e.message}", path: path }
      end

      # Write to a file
      # @param path [String] The file path
      # @param content [String] The content to write
      # @return [Hash] The result of the operation
      def write_file(path, content)
        # Create the directory if it doesn't exist
        FileUtils.mkdir_p(File.dirname(path)) unless File.directory?(File.dirname(path))
        
        File.write(path, content)
        { success: true, path: path }
      rescue StandardError => e
        { error: "Failed to write file: #{e.message}", path: path }
      end

      # List files in a directory
      # @param path [String] The directory path
      # @return [Hash] The list of files
      def list_files(path)
        files = Dir.glob(File.join(path, '*')).map do |file|
          {
            path: file,
            name: File.basename(file),
            directory: File.directory?(file),
            size: File.size(file)
          }
        end
        { files: files, path: path }
      rescue StandardError => e
        { error: "Failed to list files: #{e.message}", path: path }
      end
    end
  end
end
