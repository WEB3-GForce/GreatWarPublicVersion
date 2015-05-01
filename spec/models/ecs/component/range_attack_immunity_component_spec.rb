require_relative '../../../spec_helper'

describe RangeAttackImmunityComponent do

  let(:basic_immunity) {RangeAttackImmunityComponent.new}

  it "should be a subclass of Component" do
    expect(RangeAttackImmunityComponent < Component).to be true
  end

  it "should properly initialize itself" do
    immunity_comp = RangeAttackImmunityComponent.new
    expect(immunity_comp.class).to equal(RangeAttackImmunityComponent)
  end
end
