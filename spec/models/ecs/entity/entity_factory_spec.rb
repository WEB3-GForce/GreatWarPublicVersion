require_relative '../../../spec_helper'

describe EntityFactory do

	let(:manager) {EntityManager.new(10, 10)}
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

	it "should create a new board with flatland squares" do
		entity = EntityFactory.create_board_basic(manager)
		manager.board.each { |row|
			row.each { |col|
				expect(manager[col][TerrainComponent][0]).to eq(TerrainComponent.flatland)
			}
		}
	end

	it "should create a new human player" do
		entity = EntityFactory.human_player(manager, "David")
		expect(manager[entity][NameComponent][0].name).to eq("David")
		expect(manager[entity][HumanComponent].size).to eq(1)
	end

	it "should create a new ai player" do
		entity = EntityFactory.ai_player(manager)
		expect(manager[entity][AIComponent].size).to eq(1)
	end

end

