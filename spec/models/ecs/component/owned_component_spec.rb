require_relative '../../../spec_helper'

describe OwnedComponent do

	let(:basic_owned) {OwnedComponent.new("Marcus")}

	it "should properly initialize itself" do
		owned_comp = OwnedComponent.new("Joe")
		expect(owned_comp.owner).to eq("Joe")
	end

	it "should have implemented to_s" do
		expect(basic_owned).to respond_to :to_s
		expect(basic_owned.to_s.class).to eq(String)
	end
end
