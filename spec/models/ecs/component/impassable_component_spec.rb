require_relative '../../../spec_helper'

describe ImpassableComponent do
	it "should be able to be initialized" do
		comp = ImpassableComponent.new
		expect(comp.class).to equal(ImpassableComponent)
	end

	it "should have implemented to_s" do
		comp = ImpassableComponent.new
		expect(comp).to respond_to :to_s	
		expect(comp.to_s.class).to eq(String)
	end
end
