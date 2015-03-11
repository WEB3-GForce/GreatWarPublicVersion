require_relative '../../../spec_helper'

describe OwnedComponent do

	let(:basicOwned) {OwnedComponent.new("Marcus")}

	it "should properly initialize itself" do
		ownedComp = OwnedComponent.new("Joe")
		expect(ownedComp.owner).to eq("Joe")
	end

	it "should have implemented to_s" do
		expect(basicOwned).to respond_to :to_s
		expect(basicOwned.to_s.class).to eq(String)
	end
end
