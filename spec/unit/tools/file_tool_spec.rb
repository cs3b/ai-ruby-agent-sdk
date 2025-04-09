# frozen_string_literal: true

require 'fileutils'

RSpec.describe Aira::Tools::FileTool do
  let(:file_tool) { Aira::Tools::FileTool.new }
  let(:test_dir) { "tmp/test_files" }
  let(:test_file) { "#{test_dir}/test_file.txt" }
  let(:test_content) { "Test file content" }
  
  before do
    FileUtils.mkdir_p(test_dir)
  end
  
  after do
    FileUtils.rm_rf(test_dir) if Dir.exist?(test_dir)
  end
  
  describe "#description" do
    it "returns a description of the tool" do
      expect(file_tool.description).to be_a(String)
      expect(file_tool.description).not_to be_empty
    end
  end
  
  describe "#parameters" do
    it "defines the expected parameters" do
      params = file_tool.parameters
      expect(params.keys).to include(:path, :operation, :content)
      
      # Check path parameter
      expect(params[:path].name).to eq(:path)
      expect(params[:path].required).to be true
      
      # Check operation parameter
      expect(params[:operation].name).to eq(:operation)
      expect(params[:operation].required).to be true
      
      # Check content parameter
      expect(params[:content].name).to eq(:content)
      expect(params[:content].required).to be false
    end
  end
  
  describe "#call" do
    context "with read operation" do
      before do
        File.write(test_file, test_content)
      end
      
      it "reads the content of a file" do
        result = file_tool.call(operation: "read", path: test_file)
        expect(result[:content]).to eq(test_content)
        expect(result[:path]).to eq(test_file)
      end
      
      it "raises an error when the file doesn't exist" do
        expect {
          file_tool.call(operation: "read", path: "nonexistent_file.txt")
        }.to raise_error(Aira::Error, /File does not exist/)
      end
    end
    
    context "with write operation" do
      it "writes content to a file" do
        result = file_tool.call(operation: "write", path: test_file, content: test_content)
        expect(result[:success]).to be true
        expect(result[:path]).to eq(test_file)
        expect(File.read(test_file)).to eq(test_content)
      end
      
      it "creates parent directories if they don't exist" do
        nested_file = "#{test_dir}/nested/deeply/file.txt"
        result = file_tool.call(operation: "write", path: nested_file, content: "Nested content")
        expect(result[:success]).to be true
        expect(File.exist?(nested_file)).to be true
        expect(File.read(nested_file)).to eq("Nested content")
      end
    end
    
    context "with list operation" do
      before do
        File.write(test_file, test_content)
        File.write("#{test_dir}/another_file.txt", "Another file")
        FileUtils.mkdir_p("#{test_dir}/subdir")
        File.write("#{test_dir}/subdir/nested_file.txt", "Nested file")
      end
      
      it "lists files in a directory" do
        result = file_tool.call(operation: "list", path: test_dir)
        expect(result[:files]).to be_an(Array)
        expect(result[:files]).to include("test_file.txt", "another_file.txt", "subdir")
      end
      
      it "raises an error when the directory doesn't exist" do
        expect {
          file_tool.call(operation: "list", path: "nonexistent_dir")
        }.to raise_error(Aira::Error, /Directory does not exist/)
      end
    end
    
    context "with invalid operation" do
      it "raises an error" do
        expect {
          file_tool.call(operation: "invalid", path: test_file)
        }.to raise_error(Aira::Error, /Invalid operation/)
      end
    end
  end
end
