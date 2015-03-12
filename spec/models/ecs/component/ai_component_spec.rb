require_relative '../../../spec_helper'

describe AIComponent do

	it "should be a subclass of Component" do
		expect(AIComponent < Component).to be true
	end

	it "should be able to be initialized" do
		comp = AIComponent.new
		expect(comp.class).to equal(AIComponent)
	end
end
