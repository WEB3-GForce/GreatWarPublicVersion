require_relative '../../../spec_helper'

describe TrenchBuilderComponent do

  let(:basic_trench) {TrenchBuilderComponent.new}

  it "should be a subclass of Component" do
    expect(TrenchBuilderComponent < Component).to be true
  end

  context "when initializing" do

    it "should succeed in initializing itself" do
      trench_comp = TrenchBuilderComponent.new(10)
      expect(trench_comp.energy_cost).to eq(10)
    end
  end

  it "should have implemented to_s" do
    expect(basic_trench).to respond_to :to_s
    expect(basic_trench.to_s.class).to eq(String)
    expect(basic_trench.to_s.include? "Trench").to eq(true)
  end
end
