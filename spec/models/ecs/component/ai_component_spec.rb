require_relative '../../../spec_helper'

describe AIComponent do
	it "should be able to be initialized" do
		comp = AIComponent.new
		expect(comp.class).to equal(AIComponent)
	end

	it "should have implemented to_s" do
		comp = AIComponent.new
		expect(comp).to respond_to :to_s	
		expect(comp.to_s.class).to eq(String)
	end
end
