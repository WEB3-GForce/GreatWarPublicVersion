require_relative '../../../spec_helper'

describe Component do
	it "should be able to be initialized" do
		comp = Component.new
		expect(comp.class).to equal(Component)
	end
end
