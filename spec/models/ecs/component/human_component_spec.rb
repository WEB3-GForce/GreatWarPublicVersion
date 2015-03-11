require_relative '../../../spec_helper'

describe HumanComponent do
	it "should be able to be initialized" do
		comp = HumanComponent.new
		expect(comp.class).to equal(HumanComponent)
	end
end
