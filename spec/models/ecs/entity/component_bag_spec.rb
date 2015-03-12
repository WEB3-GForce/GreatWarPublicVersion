require_relative '../../../spec_helper'

describe ComponentBag do

	it "should be a subclass of Hash" do
		expect(ComponentBag < Hash).to be true
	end

	context "when initialized" do
		it "should default to an empty array" do
			bag = ComponentBag.new
			expect(bag["new item"]).to eq([])
		end
	end

	it "should map component classes to an array of class instances" do
		bag              = ComponentBag.new
		ai_array         = [AIComponent.new, AIComponent.new]
		bag[AIComponent] = ai_array
		expect(bag[AIComponent]).to eq(ai_array)
	end
end
