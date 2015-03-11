require_relative '../../../spec_helper'

describe PositionComponent do

	let(:basicPosition) {PositionComponent.new(10, 20)}

	it "should properly initialize itself" do
		positionComp = PositionComponent.new(5, 10)
		expect(positionComp.row).to eq(5)
		expect(positionComp.col).to eq(10)
	end

	it "should have implemented to_s" do
		expect(basicPosition).to respond_to :to_s
		expect(basicPosition.to_s.class).to eq(String)
	end
end
