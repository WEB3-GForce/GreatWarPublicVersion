require_relative '../../../spec_helper'

describe NameComponent do

	let(:basicName) {NameComponent.new("Stan Lee")}

	it "should properly initialize itself" do
		nameComp = NameComponent.new("Thomas")
		expect(nameComp.name).to eq("Thomas")
	end

	it "should have implemented to_s" do
		expect(basicName).to respond_to :to_s
		expect(basicName.to_s.class).to eq(String)
	end
end
