require_relative '../../../spec_helper'

describe ImpassableComponent do

  it "should be a subclass of Component" do
    expect(ImpassableComponent < Component).to be true
  end

  it "should be able to be initialized" do
    comp = ImpassableComponent.new
    expect(comp.class).to equal(ImpassableComponent)
  end
end
