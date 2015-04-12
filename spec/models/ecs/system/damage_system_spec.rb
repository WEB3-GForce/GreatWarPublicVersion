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

describe DamageSystem do

	let(:manager)    {EntityManager.new(3, 3)}
	let(:human1)     {EntityFactory.human_player(manager, "David")}
	let(:infantry)   {debug_infantry(manager, human1)}
	let(:flatland)   {EntityFactory.flatland_square(manager)}
	let(:row)        {1}
	let(:col)        {1}

	def setup
		manager.add_component(flatland,
				      PositionComponent.new(row, col))
		manager.board[row][col] = [flatland, []]
	end

	it "should be a subclass of System" do
		expect(DamageSystem < System).to be true
	end

	context "when calling update" do
	
		it "should return [] if the entity is not damageable" do
			result = DamageSystem.update(manager, flatland, 5)
			expect(result).to eq []
		end

		it "should return the proper array for live damageable entities" do
			setup()
			manager.board[row][col][1].push infantry
			manager.add_component(infantry,
					      PositionComponent.new(row, col))
			result = DamageSystem.update(manager, infantry, 5)
			expect(result).to eq [[infantry, 1, 1, 5]]
		end

		it "should return the proper array for dead entities" do
			setup()
			manager.board[row][col][1].push infantry
			manager.add_component(infantry,
					      PositionComponent.new(row, col))
			result = DamageSystem.update(manager, infantry, 10)
			expect(result.size).to eq 2
			expect(result[0]).to eq [infantry, 1, 1, 10]
			expect(result[1][0]).to eq "kill"
		end
	end
end
