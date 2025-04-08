# frozen_string_literal: true

RSpec.describe Aira do
  it "has a version number" do
    expect(Aira::VERSION).not_to be nil
  end

  it "follows semantic versioning format" do
    expect(Aira::VERSION).to match(/^\d+\.\d+\.\d+(?:-[\w\d\.]+)?(?:\+[\w\d\.]+)?$/)
  end
end
