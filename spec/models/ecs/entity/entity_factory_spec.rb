require_relative '../../../spec_helper'

describe EntityFactory do

	let(:manager) {EntityManager.new}
	let(:ai)      {AIComponent.new}
	let(:ai)      {AIComponent.new}
	let(:human)   {HumanComponent.new}

	it "should create a new entity" do
		entity = EntityFactory.create_entity(manager, [ai, human])
		expect(manager[entity][AIComponent]).to eq([ai])
		expect(manager[entity][HumanComponent]).to eq([human])
	end

	it "should create a new flatland square" do
		entity = EntityFactory.flatland_square(manager)
		expect(manager[entity][TerrainComponent][0]).to eq(TerrainComponent.flatland)
		expect(manager[entity][OccupiableComponent].size).to eq(1)
		expect(manager[entity][ImpassableComponent].size).to eq(0)
	end

	it "should create a new mountain square" do
		entity = EntityFactory.mountain_square(manager)
		expect(manager[entity][TerrainComponent][0]).to eq(TerrainComponent.mountain)
		expect(manager[entity][ImpassableComponent].size).to eq(1)
		expect(manager[entity][OccupiableComponent].size).to eq(0)
	end

	it "should create a new hill square" do
		entity = EntityFactory.hill_square(manager)
		expect(manager[entity][TerrainComponent][0]).to eq(TerrainComponent.hill)
		expect(manager[entity][OccupiableComponent].size).to eq(1)
		expect(manager[entity][ImpassableComponent].size).to eq(0)
	end

	it "should create a new trench square" do
		entity = EntityFactory.trench_square(manager)
		expect(manager[entity][TerrainComponent][0]).to eq(TerrainComponent.trench)
		expect(manager[entity][OccupiableComponent].size).to eq(1)
		expect(manager[entity][ImpassableComponent].size).to eq(0)
	end

	it "should create a new river square" do
		entity = EntityFactory.river_square(manager)
		expect(manager[entity][TerrainComponent][0]).to eq(TerrainComponent.river)
		expect(manager[entity][ImpassableComponent].size).to eq(0)
		expect(manager[entity][OccupiableComponent].size).to eq(0)
	end
end

