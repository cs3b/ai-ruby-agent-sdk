require_relative "lib/aira/version"

Gem::Specification.new do |spec|
  spec.name = "airarb"
  spec.version = Aira::VERSION
  spec.authors = ["Michal Czyz"]
  spec.email = ["opensource@cs3b.com"]

  spec.summary = "Ruby SDK for building AI agents"
  spec.description = "An elegant Ruby SDK for building AI Ruby Agent that interact with both LLMs and system tools"
  spec.homepage = "https://github.com/cs3b/ai-ruby-agent-sdk"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.4.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  spec.files = Dir.glob(%w[
    lib/**/*
    README.md
    LICENSE
    CHANGELOG.md
  ])
  spec.require_paths = ["lib"]

  spec.add_dependency "ruby_llm"
end
