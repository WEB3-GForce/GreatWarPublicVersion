require_relative '../../../spec_helper'

describe Component do
	it "should be able to be initialized" do
		comp = Component.new
		expect(comp.class).to equal(Component)
	end

	it "should have implement to_s" do
		comp = Component.new
		expect(comp).to respond_to :to_s	
		expect(comp.to_s.class).to eq(String)
	end
end
