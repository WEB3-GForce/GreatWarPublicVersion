require_relative '../../../spec_helper'

describe ImpassableComponent do
	it "should be able to be initialized" do
		comp = ImpassableComponent.new
		expect(comp.class).to equal(ImpassableComponent)
	end
end
