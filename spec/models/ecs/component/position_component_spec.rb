require_relative '../../../spec_helper'

describe PositionComponent do

  let(:basic_position) {PositionComponent.new(10, 20)}
  let(:basic_position2) {PositionComponent.new(20, 10)}

  it "should be a subclass of Component" do
    expect(PositionComponent < Component).to be true
  end

  it "should properly initialize itself" do
    expect(basic_position.distance_to(basic_position2)).to be 20
  end

  it "should properly initialize itself" do
    position_comp = PositionComponent.new(5, 10)
    expect(position_comp.row).to eq(5)
    expect(position_comp.col).to eq(10)
  end

  it "should have implemented to_s" do
    expect(basic_position).to respond_to :to_s
    expect(basic_position.to_s.class).to eq(String)
  end
end
