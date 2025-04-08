# frozen_string_literal: true

RSpec.describe RubyAIAgent do
  it "has a version number" do
    expect(RubyAIAgent::VERSION).not_to be nil
  end

  it "follows semantic versioning format" do
    expect(RubyAIAgent::VERSION).to match(/^\d+\.\d+\.\d+(?:-[\w\d\.]+)?(?:\+[\w\d\.]+)?$/)
  end
end
