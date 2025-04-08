# Aidarb - AI Ruby Agent SDK

> **Note**: This SDK is currently under active development and not ready for production use. Star and watch the repo to stay updated on our progress!

[![Gem Version](https://badge.fury.io/rb/aidarb.svg)](https://badge.fury.io/rb/aidarb)
[![Build Status](https://github.com/cs3b/ai-ruby-agent-sdk/workflows/CI/badge.svg)](https://github.com/cs3b/ai-ruby-agent-sdk/actions)
[![Maintainability](https://api.codeclimate.com/v1/badges/a7d04c3bebb64d30cd42/maintainability)](https://codeclimate.com/github/cs3b/ai-ruby-agent-sdk/maintainability)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

An elegant Ruby SDK for building AI agents that interact with both LLMs and system tools. The SDK follows a minimalist philosophy focusing on three core components:

- 🌍 **Environment**: File-based agent communication and queueing
- 🛠️ **Tools**: A unified registry for various capabilities (browser control, file operations, etc.)
- 💬 **Prompt**: ERB templates for natural Ruby-style prompt interpolation

## Philosophy

Not every problem needs an agent. Use agents when tasks are:
- Complex with multiple steps
- Valuable enough to justify LLM costs
- Ambiguous requiring intelligence

Keep agents simple and focused - this enables faster iteration and better understanding of their behavior.

## Installation

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add aidarb
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install aidarb
```

## Usage

```ruby
require 'aira'

# Create a web content extractor agent
agent :web_extractor do
  description "Extract main content from a webpage and save as markdown"

  input :url
  output :markdown_file

  tools :web_browser, :markdown_converter

  prompt <<-ERB
    Given the URL <%= url %>, extract the main content.
    Return the result as a markdown document.
  ERB

  # Optional validation loop
  loop do |context|
    File.exist?(context[:markdown_file])
  end
end

# Create a summarization agent
agent :summarizer do
  description "Create a concise summary of markdown content"

  input :markdown_file
  output :summary

  tools :file_ops

  prompt <<-ERB
    Read the markdown from <%= markdown_file %>
    Create a concise summary focusing on key points.
  ERB
end

# Run the agents in sequence
context = {url: "https://example.com/article"}
web_extractor.run(context)
summarizer.run(context)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/cs3b/ai-ruby-agent-sdk.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
