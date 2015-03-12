require_relative '../../../spec_helper'

describe NameComponent do

	let(:basic_name) {NameComponent.new("Stan Lee")}

	it "should properly initialize itself" do
		name_comp = NameComponent.new("Thomas")
		expect(name_comp.name).to eq("Thomas")
	end

	it "should have implemented to_s" do
		expect(basic_name).to respond_to :to_s
		expect(basic_name.to_s.class).to eq(String)
	end
end
