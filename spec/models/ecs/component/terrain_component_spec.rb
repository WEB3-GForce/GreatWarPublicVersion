require_relative '../../../spec_helper'

describe TerrainComponent do

	it "should be a subclass of Component" do
		expect(TerrainComponent < Component).to be true
	end

	it "should properly initialize itself" do
		terrain_comp = TerrainComponent.new("land")
		expect(terrain_comp.type).to eq("land")
	end

	it "should have a flatland terrain" do
		expect(TerrainComponent.flatland.type).to eq(:flatland)
	end

	it "should have a mountain terrain" do
		expect(TerrainComponent.mountain.type).to eq(:mountain)
	end

	it "should have a hill terrain" do
		expect(TerrainComponent.hill.type).to eq(:hill)
	end

	it "should have a trench terrain" do
		expect(TerrainComponent.trench.type).to eq(:trench)
	end

	it "should have a river terrain" do
		expect(TerrainComponent.river.type).to eq(:river)
	end

	it "should have implemented to_s" do
		expect(TerrainComponent.flatland).to respond_to :to_s
		expect(TerrainComponent.flatland.to_s.class).to eq(String)
	end
end
