require_relative '../../../spec_helper'

describe OccupiableComponent do

  it "should be a subclass of Component" do
    expect(OccupiableComponent < Component).to be true
  end

  it "should be able to be initialized" do
    comp = OccupiableComponent.new
    expect(comp.class).to equal(OccupiableComponent)
  end

  it "should have implemented to_s" do
    comp = OccupiableComponent.new
    expect(comp).to respond_to :to_s
    expect(comp.to_s.class).to eq(String)
  end
end
