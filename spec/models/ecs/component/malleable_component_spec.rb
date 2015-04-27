require_relative '../../../spec_helper'

describe MalleableComponent do

	it "should be a subclass of Component" do
		expect(MalleableComponent < Component).to be true
	end

	it "should be able to be initialized" do
		comp = MalleableComponent.new
		expect(comp.class).to equal(MalleableComponent)
	end
end
