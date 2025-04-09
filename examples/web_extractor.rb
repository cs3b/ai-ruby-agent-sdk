# frozen_string_literal: true

require 'aira'

# Define a web extractor agent
Aira.agent :web_extractor do
  description "Extract main content and comments from a webpage and save as markdown."
  
  # Define input and output
  input :url
  output :markdown_file
  
  # Define the prompt template using ERB
  prompt <<~PROMPT
    Given the URL <%= url %>, extract the main content and any user comments.
    Return the result as a markdown document.
  PROMPT
  
  # Specify the tools this agent can use
  tools :web_browser, :markdown_converter
  
  # Define the source and output directories
  source_directory 'jobs/web_extraction'
  output_directory 'results/web_extraction'
  
  # Define a multi-step workflow
  steps do
    step :fetch_content, using: :web_browser do |context|
      puts "Fetching content from #{context[:url]}..."
      # In a real implementation, you would use a web browser tool
      context[:html_content] = "<html><body><h1>Example Page</h1><p>This is sample content.</p></body></html>"
    end
    
    step :convert_to_markdown, using: :markdown_converter do |context|
      puts "Converting HTML to markdown..."
      # In a real implementation, you would use a markdown converter tool
      context[:markdown_content] = "# Example Page\n\nThis is sample content."
      
      # Save to file
      output_file = "#{context[:url].gsub(/[^\w]/, '_')}.md"
      context[:markdown_file] = output_file
      
      # In a real implementation, you would save to the output directory
      puts "Saved markdown to #{output_file}"
    end
  end
  
  # Define a loop block to verify completion
  loop do |context|
    puts "Verifying extraction completed for #{context[:url]}..."
    # In a real implementation, you might check if the file exists
    break if context[:markdown_file]
    sleep 1
  end
  
  # Define a review block to validate the output
  review do |context|
    puts "Reviewing extraction result for #{context[:url]}..."
    # In a real implementation, you might validate the content
    puts "Extraction successful: #{context[:markdown_file]}"
  end
end

# Run the agent with a sample URL
if __FILE__ == $PROGRAM_NAME
  puts "Running web extractor agent..."
  agent = Aira::Registry.get(:web_extractor)
  result = agent.run(url: "https://example.com")
  puts "Result: #{result.inspect}"
end
