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
      # @param params [Hash] The parameters
      # @return [Hash] The result of the operation
      def call(params)
        path = params[:path]
        operation = params[:operation]
        content = params[:content]
        
        case operation.to_s.downcase
        when 'read'
          read_file(path)
        when 'write'
          raise Aira::Error, "Content is required for write operations" unless content
          write_file(path, content)
        when 'list'
          list_files(path)
        else
          raise Aira::Error, "Invalid operation: #{operation}. Must be one of: read, write, list"
        end
      end

      private

      # Read a file
      # @param path [String] The file path
      # @return [Hash] The file content
      def read_file(path)
        unless File.exist?(path)
          raise Aira::Error, "File does not exist: #{path}"
        end
        
        content = File.read(path)
        { content: content, path: path }
      rescue StandardError => e
        raise Aira::Error, "Failed to read file: #{e.message}"
      end

      # Write to a file
      # @param path [String] The file path
      # @param content [String] The content to write
      # @return [Hash] The result of the operation
      def write_file(path, content)
        # Create parent directories if they don't exist
        FileUtils.mkdir_p(File.dirname(path))
        
        File.write(path, content)
        { success: true, path: path }
      rescue StandardError => e
        raise Aira::Error, "Failed to write file: #{e.message}"
      end

      # List files in a directory
      # @param path [String] The directory path
      # @return [Hash] The list of files
      def list_files(path)
        unless Dir.exist?(path)
          raise Aira::Error, "Directory does not exist: #{path}"
        end
        
        files = Dir.entries(path).reject { |f| f == '.' || f == '..' }
        { files: files, path: path }
      rescue StandardError => e
        raise Aira::Error, "Failed to list files: #{e.message}"
      end
    end
  end
end
