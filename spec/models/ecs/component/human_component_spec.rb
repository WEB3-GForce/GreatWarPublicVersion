require_relative '../../../spec_helper'

describe HumanComponent do
	it "should be able to be initialized" do
		comp = HumanComponent.new
		expect(comp.class).to equal(HumanComponent)
	end

	it "should have implemented to_s" do
		comp = HumanComponent.new
		expect(comp).to respond_to :to_s	
		expect(comp.to_s.class).to eq(String)
	end
end
