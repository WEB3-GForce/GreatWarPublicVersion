require_relative '../../../spec_helper'

describe RangeAttackImmunityComponent do

	let(:basicImmunity) {RangeAttackImmunityComponent.new}

	it "should properly initialize itself" do
		immunityComp = RangeAttackImmunityComponent.new
		expect(immunityComp.class).to equal(RangeAttackImmunityComponent)
	end

	it "should have implemented to_s" do
		expect(basicImmunity).to respond_to :to_s
		expect(basicImmunity.to_s.class).to eq(String)
	end
end
