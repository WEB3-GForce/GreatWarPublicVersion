require_relative '../../../spec_helper'

describe EntityType do

	let(:manager)                {EntityManager.new(10, 20)}
	let(:flatland_entity)        {EntityFactory.flatland_square(manager)}
	let(:mountain_entity)        {EntityFactory.mountain_square(manager)}
	let(:hill_entity)            {EntityFactory.hill_square(manager)}
	let(:trench_entity)          {EntityFactory.trench_square(manager)}
	let(:river_entity)           {EntityFactory.river_square(manager)}
	let(:human_entity)           {EntityFactory.human_player(manager, "David")}
	let(:ai_entity)              {EntityFactory.ai_player(manager, "CPU 1")}
	let(:turn_entity)            {EntityFactory.turn_entity(manager, [human_entity, ai_entity])}
	let(:infantry_entity)        {EntityFactory.infantry(manager, human_entity)}
	let(:machine_gun_entity)     {EntityFactory.machine_gun(manager, human_entity)}
	let(:artillery_entity)       {EntityFactory.artillery(manager, human_entity)}
	let(:command_bunker_entity)  {EntityFactory.command_bunker(manager, human_entity)}

	# Note: False positive tests are mainly desired to ensure that EntityType
	#       does not falsely identify entities as a type.
	#
	#       They additionally make statements on what types of entities the
	#       current set of entities of the game (esp. pieces like machine_gun,
	#       infantry, etc.) should have.
	#
	#       In general, if a false positive test fails due to changes in code,
	#       it should be taken seriously.
	#
	#       However, if the change is desireable (such as wanting to make
	#       an entity moveable which wasn't before), simply change the tests.
	#
	context "when calling square_entity?" do

		it "should properly identify square entities" do
			expect(EntityType.square_entity?(manager, flatland_entity)).to be true
			expect(EntityType.square_entity?(manager, mountain_entity)).to be true
			expect(EntityType.square_entity?(manager, hill_entity)).to be true
			expect(EntityType.square_entity?(manager, trench_entity)).to be true
			expect(EntityType.square_entity?(manager, river_entity)).to be true
		end

		it "should properly not produce false positives" do
			expect(EntityType.square_entity?(manager, ai_entity)).to be false
		end
	end

	context "when calling human_player_entity?" do

		it "should properly identify human player entities" do
			expect(EntityType.human_player_entity?(manager, human_entity)).to be true
		end

		it "should properly not produce false positives" do
			expect(EntityType.human_player_entity?(manager, ai_entity)).to be false
		end
	end

	context "when calling ai_player_entity?" do

		it "should properly identify ai player entities" do
			expect(EntityType.ai_player_entity?(manager, ai_entity)).to be true
		end

		it "should properly not produce false positives" do
			expect(EntityType.ai_player_entity?(manager, human_entity)).to be false
		end
	end

	context "when calling turn_entity?" do

		it "should properly identify turn entities" do
			expect(EntityType.turn_entity?(manager, turn_entity)).to be true
		end

		it "should properly not produce false positives" do
			expect(EntityType.turn_entity?(manager, ai_entity)).to be false
		end
	end

	context "when calling piece_entity?" do

		it "should properly identify piece entities" do
			expect(EntityType.piece_entity?(manager, infantry_entity)).to be true
			expect(EntityType.piece_entity?(manager, machine_gun_entity)).to be true
			expect(EntityType.piece_entity?(manager, artillery_entity)).to be true
			expect(EntityType.piece_entity?(manager, command_bunker_entity)).to be true
		end

		it "should properly not produce false positives" do
			expect(EntityType.piece_entity?(manager, ai_entity)).to be false
		end
	end

	context "when calling placed_entity?" do

		it "should properly identify placed entities" do
			manager.add_component(infantry_entity, PositionComponent.new(1, 2))
			manager.add_component(machine_gun_entity, PositionComponent.new(2, 2))
			manager.add_component(artillery_entity, PositionComponent.new(3, 2))
			manager.add_component(command_bunker_entity, PositionComponent.new(3, 3))
			manager.add_component(flatland_entity, PositionComponent.new(3, 3))
			expect(EntityType.placed_entity?(manager, infantry_entity)).to be true
			expect(EntityType.placed_entity?(manager, machine_gun_entity)).to be true
			expect(EntityType.placed_entity?(manager, artillery_entity)).to be true
			expect(EntityType.placed_entity?(manager, command_bunker_entity)).to be true
			expect(EntityType.placed_entity?(manager, flatland_entity)).to be true
		end

		it "should properly not produce false positives" do
			expect(EntityType.placed_entity?(manager, ai_entity)).to be false
		end
	end

	context "when calling moveable_entity?" do

		it "should properly identify moveable entities" do
			manager.add_component(infantry_entity, PositionComponent.new(1, 2))
			manager.add_component(machine_gun_entity, PositionComponent.new(2, 2))
			manager.add_component(artillery_entity, PositionComponent.new(3, 2))
			expect(EntityType.moveable_entity?(manager, infantry_entity)).to be true
			expect(EntityType.moveable_entity?(manager, machine_gun_entity)).to be true
			expect(EntityType.moveable_entity?(manager, artillery_entity)).to be true
		end

		it "should properly not produce false positives" do
			expect(EntityType.moveable_entity?(manager, command_bunker_entity)).to be false
			expect(EntityType.moveable_entity?(manager, ai_entity)).to be false
		end
	end

	context "when calling energy_entity?" do

		it "should properly identify energy entities" do
			expect(EntityType.energy_entity?(manager, infantry_entity)).to be true
			expect(EntityType.energy_entity?(manager, machine_gun_entity)).to be true
			expect(EntityType.energy_entity?(manager, artillery_entity)).to be true
			expect(EntityType.energy_entity?(manager, command_bunker_entity)).to be true
		end

		it "should properly not produce false positives" do
			expect(EntityType.energy_entity?(manager, ai_entity)).to be false
		end
	end

	context "when calling melee_entity?" do

		it "should properly identify melee entities" do
			expect(EntityType.melee_entity?(manager, infantry_entity)).to be true
			expect(EntityType.melee_entity?(manager, machine_gun_entity)).to be true
		end

		it "should properly not produce false positives" do
			expect(EntityType.melee_entity?(manager, command_bunker_entity)).to be false
			expect(EntityType.melee_entity?(manager, artillery_entity)).to be false
			expect(EntityType.melee_entity?(manager, ai_entity)).to be false
		end
	end

	context "when calling range_entity?" do

		it "should properly identify range entities" do
			expect(EntityType.range_entity?(manager, infantry_entity)).to be true
			expect(EntityType.range_entity?(manager, machine_gun_entity)).to be true
			expect(EntityType.range_entity?(manager, artillery_entity)).to be true
		end

		it "should properly not produce false positives" do
			expect(EntityType.range_entity?(manager, command_bunker_entity)).to be false
			expect(EntityType.range_entity?(manager, ai_entity)).to be false
		end
	end

	context "when calling range_immuned_entity?" do

		it "should properly identify range entities" do
			expect(EntityType.range_immuned_entity?(manager, command_bunker_entity)).to be true
		end

		it "should properly not produce false positives" do
			expect(EntityType.range_immuned_entity?(manager, ai_entity)).to be false
			expect(EntityType.range_immuned_entity?(manager, infantry_entity)).to be false
			expect(EntityType.range_immuned_entity?(manager, machine_gun_entity)).to be false
			expect(EntityType.range_immuned_entity?(manager, artillery_entity)).to be false
		end
	end

	context "when calling damageable_entity?" do

		it "should properly identify damageable entities" do
			expect(EntityType.damageable_entity?(manager, infantry_entity)).to be true
			expect(EntityType.damageable_entity?(manager, machine_gun_entity)).to be true
			expect(EntityType.damageable_entity?(manager, artillery_entity)).to be true
			expect(EntityType.damageable_entity?(manager, command_bunker_entity)).to be true
		end

		it "should properly not produce false positives" do
			expect(EntityType.damageable_entity?(manager, ai_entity)).to be false
		end
	end
end
