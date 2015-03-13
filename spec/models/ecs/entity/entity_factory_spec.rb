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
		manager.board.each_with_index { |ele, row|
			ele.each_with_index { |_, col|
				square = manager.board[row][col]
				pos_comp = manager[square][PositionComponent][0]
				ter_comp = manager[square][TerrainComponent][0]
				expect(ter_comp).to eq(TerrainComponent.flatland)
				expect(pos_comp.row).to eq(row)
				expect(pos_comp.col).to eq(col)
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

	it "should create a new infantry piece" do
		owner = EntityFactory.human_player(manager, "David")
		entity = EntityFactory.infantry(manager, owner)
		
		unit_comp   = manager[entity][PieceComponent][0]
		health_comp = manager[entity][HealthComponent][0]
		motion_comp = manager[entity][MotionComponent][0]
		melee_comp  = manager[entity][MeleeAttackComponent][0]
		range_comp  = manager[entity][RangeAttackComponent][0]
		owned_comp  = manager[entity][OwnedComponent][0]
		
		expect(unit_comp.type).to eq(:infantry)
		expect(health_comp.cur_health).to eq(10)
		expect(health_comp.max_health).to eq(10)
		expect(motion_comp.cur_movement).to eq(5)
		expect(motion_comp.base_movement).to eq(5)
		expect(melee_comp.attack).to eq(10)
		expect(range_comp.attack).to eq(10)
		expect(range_comp.min_range).to eq(1)
		expect(range_comp.max_range).to eq(4)
		expect(owned_comp.owner).to eq(owner)
	end

	it "should create a new machine gun piece" do
		owner = EntityFactory.human_player(manager, "David")
		entity = EntityFactory.machine_gun(manager, owner)
		
		unit_comp   = manager[entity][PieceComponent][0]
		health_comp = manager[entity][HealthComponent][0]
		motion_comp = manager[entity][MotionComponent][0]
		melee_comp  = manager[entity][MeleeAttackComponent][0]
		range_comp  = manager[entity][RangeAttackComponent][0]
		owned_comp  = manager[entity][OwnedComponent][0]
		
		expect(unit_comp.type).to eq(:machine_gun)
		expect(health_comp.cur_health).to eq(20)
		expect(health_comp.max_health).to eq(20)
		expect(motion_comp.cur_movement).to eq(3)
		expect(motion_comp.base_movement).to eq(3)
		expect(melee_comp.attack).to eq(10)
		expect(range_comp.attack).to eq(10)
		expect(range_comp.min_range).to eq(3)
		expect(range_comp.max_range).to eq(7)
		expect(owned_comp.owner).to eq(owner)
	end

	it "should create a new artillery piece" do
		owner = EntityFactory.human_player(manager, "David")
		entity = EntityFactory.artillery(manager, owner)
		
		unit_comp   = manager[entity][PieceComponent][0]
		health_comp = manager[entity][HealthComponent][0]
		motion_comp = manager[entity][MotionComponent][0]
		melee_comp  = manager[entity][MeleeAttackComponent][0]
		range_comp  = manager[entity][RangeAttackComponent][0]
		owned_comp  = manager[entity][OwnedComponent][0]
		
		expect(unit_comp.type).to eq(:artillery)
		expect(health_comp.cur_health).to eq(10)
		expect(health_comp.max_health).to eq(10)
		expect(motion_comp.cur_movement).to eq(1)
		expect(motion_comp.base_movement).to eq(1)
		expect(melee_comp.attack).to eq(0)
		expect(range_comp.attack).to eq(20)
		expect(range_comp.min_range).to eq(5)
		expect(range_comp.max_range).to eq(15)
		expect(owned_comp.owner).to eq(owner)
	end

	it "should create a new command_bunker piece" do
		owner  = EntityFactory.human_player(manager, "David")
		entity = EntityFactory.command_bunker(manager, owner)
		
		unit_comp      = manager[entity][PieceComponent][0]
		health_comp    = manager[entity][HealthComponent][0]
		immunity_comp  = manager[entity][RangeAttackImmunityComponent][0]
		owned_comp     = manager[entity][OwnedComponent][0]
		
		expect(unit_comp.type).to eq(:command_bunker)
		expect(health_comp.cur_health).to eq(30)
		expect(health_comp.max_health).to eq(30)
		expect(immunity_comp.class).to eq(RangeAttackImmunityComponent)
		expect(owned_comp.owner).to eq(owner)
	end
end

