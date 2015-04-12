require_relative '../../../spec_helper'

def debug_infantry(entity_manager, owner)
	return EntityFactory.create_entity(entity_manager,
				  [PieceComponent.infantry,
				   HealthComponent.new(10),
				   EnergyComponent.new(10),
				   MotionComponent.new(5),
				   MeleeAttackComponent.new(10),
				   RangeAttackComponent.new(10, 1, 4),
				   OwnedComponent.new(owner)])
end

describe EnergySystem do

	let(:manager)               {EntityManager.new(10, 20)}
	let(:human)                 {EntityFactory.human_player(manager, "David")}
	let(:human2)                {EntityFactory.human_player(manager, "Goliath")}
	let(:turn_entity)           {EntityFactory.turn_entity(manager, [human, human2])}
	let(:flatland)              {EntityFactory.flatland_square(manager)}
	let(:infantry)              {debug_infantry(manager, human)}
	let(:infantry2)             {debug_infantry(manager, human)}
	let(:foe)                   {debug_infantry(manager, human2)}
	let(:foe2)                  {debug_infantry(manager, human2)}

	it "should be a subclass of System" do
		expect(EnergySystem < System).to be true
	end

	context "when calling enough_energy?" do
	
		it "should fail if the entity does not use energy" do
			result = EnergySystem.enough_energy?(manager, human, 10)
			expect(result).to be false
		end
	
		it "should return true if enough energy" do
			result = EnergySystem.enough_energy?(manager, infantry, 0)
			expect(result).to be true
		end	

	
		it "should return false if not enough energy" do
			result = EnergySystem.enough_energy?(manager, infantry, 1000)
			expect(result).to be false
		end	
	end

	context "when calling consume_energy" do
	
		it "should fail if the entity does not use energy" do
			result = EnergySystem.consume_energy(manager, human, 10)
			expect(result).to be false
		end
	
		it "should return true if enough energy" do
			manager[infantry].delete MotionComponent
			result = EnergySystem.consume_energy(manager, infantry, 5)
			expect(result).to be true
			
			energy_comp = manager[infantry][EnergyComponent].first
			expect(energy_comp.cur_energy).to be 5
		end	

		it "should update moveable entities appropriately" do
			manager.add_component(infantry, PositionComponent.new(1, 1))
			result = EnergySystem.consume_energy(manager, infantry, 5)
			expect(result).to be true
			
			energy_comp = manager[infantry][EnergyComponent].first
			motion_comp = manager[infantry][MotionComponent].first
			expect(energy_comp.cur_energy).to be 5
			expect(motion_comp.max_movement).to be (5 / motion_comp.energy_cost)
		end
	end

	context "when calling reset_energy" do
	
		def setup
			EnergySystem.consume_energy(manager, infantry, 10)
			EnergySystem.consume_energy(manager, infantry2, 10)
			EnergySystem.consume_energy(manager, foe, 10)
			EnergySystem.consume_energy(manager, foe2, 10)
			expect(manager[infantry][EnergyComponent].first.cur_energy).to eq 0
			expect(manager[infantry2][EnergyComponent].first.cur_energy).to eq 0
			expect(manager[foe][EnergyComponent].first.cur_energy).to eq 0
			expect(manager[foe2][EnergyComponent].first.cur_energy).to eq 0
		end
	
		it "should not fail but skip over owned entities without energy" do
			manager.add_component(flatland, OwnedComponent.new(human))
			manager[turn_entity][TurnComponent].first
			EnergySystem.reset_energy(manager)
		end
	
		it "should update the appropriate entities for player 1" do
			setup
			manager[turn_entity][TurnComponent].first
			EnergySystem.reset_energy(manager)
			expect(manager[infantry][EnergyComponent].first.cur_energy).to eq 10
			expect(manager[infantry2][EnergyComponent].first.cur_energy).to eq 10
			expect(manager[foe][EnergyComponent].first.cur_energy).to eq 0
			expect(manager[foe2][EnergyComponent].first.cur_energy).to eq 0
		end

		it "should update the appropriate entities for player 2" do
			setup
			manager[turn_entity][TurnComponent].first.next_turn
			EnergySystem.reset_energy(manager) 
			expect(manager[infantry][EnergyComponent].first.cur_energy).to eq 0
			expect(manager[infantry2][EnergyComponent].first.cur_energy).to eq 0
			expect(manager[foe][EnergyComponent].first.cur_energy).to eq 10
			expect(manager[foe2][EnergyComponent].first.cur_energy).to eq 10
		end
	end

end
