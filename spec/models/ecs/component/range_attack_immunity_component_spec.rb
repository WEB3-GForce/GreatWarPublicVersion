require_relative '../../../spec_helper'

describe RangeAttackImmunityComponent do

	let(:basic_immunity) {RangeAttackImmunityComponent.new}

	it "should properly initialize itself" do
		immunity_comp = RangeAttackImmunityComponent.new
		expect(immunity_comp.class).to equal(RangeAttackImmunityComponent)
	end

	it "should have implemented to_s" do
		expect(basic_immunity).to respond_to :to_s
		expect(basic_immunity.to_s.class).to eq(String)
	end
end
