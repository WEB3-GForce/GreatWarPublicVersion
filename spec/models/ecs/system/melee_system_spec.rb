require_relative '../../../spec_helper'

describe MeleeSystem do

	let(:manager)    {EntityManager.new(3, 3)}
	let(:human1)     {EntityFactory.human_player(manager, "David")}
	let(:infantry)   {EntityFactory.infantry(manager, human1)}
	let(:infantry2)  {EntityFactory.infantry(manager, human1)}
	let(:flatland)   {EntityFactory.flatland_square(manager)}
	let(:row)        {1}
	let(:col)        {1}

	def setup
		manager.add_component(infantry,
				      PositionComponent.new(row, col))
		manager.add_component(infantry2,
				      PositionComponent.new(row+1, col))
	
		manager.add_component(flatland,
				      PositionComponent.new(row, col))
		manager.add_component(flatland,
				      PositionComponent.new(row+1, col))
		manager.board[row][col] = [flatland, [infantry]]
		manager.board[row+1][col] = [flatland, [infantry2]]
	end
	
	before(:each) do
		setup()
	end

	it "should be a subclass of System" do
		expect(MeleeSystem < System).to be true
	end

	context "when calling valid_melee?" do
	
		it "should fail if entity1 is not a melee_entity" do
			manager[infantry].delete MeleeAttackComponent
			result = MeleeSystem.valid_melee?(manager, infantry, infantry2)
			expect(result).to be false
		end

		it "should fail if entity2 is not damageable" do
			manager[infantry2].delete HealthComponent
			result = MeleeSystem.valid_melee?(manager, infantry, infantry2)
			expect(result).to be false
		end

		it "should fail if the entities are not adjacent" do
			manager[infantry2].delete PositionComponent
			manager.add_component(infantry2,
				      PositionComponent.new(0, 0))
			result = MeleeSystem.valid_melee?(manager, infantry, infantry2)
			expect(result).to be false
		end

		it "should return the proper array for dead entities" do
			result = MeleeSystem.valid_melee?(manager, infantry, infantry2)
			expect(result).to be true
		end
	end

	context "when calling perform_attack" do
	
		it "should return a [] result from no damage" do
			manager[infantry2].delete HealthComponent
			result = MeleeSystem.perform_attack(manager, infantry, infantry2)
			expect(result).to eq []
		end

		it "should return proper array from damage" do
			manager[infantry].delete MeleeAttackComponent
			manager.add_component(infantry,
				      MeleeAttackComponent.new(5))
			result = MeleeSystem.perform_attack(manager, infantry, infantry2)
			expect(result.size).to eq 1
			expect(result[0][0]).to eq "melee"
		end

		it "should return proper array from damage and kill" do
			result = MeleeSystem.perform_attack(manager, infantry, infantry2)
			expect(result.size).to eq 2
			expect(result[0][0]).to eq "melee"
			expect(result[1][0]).to eq "kill"
		end
	end

	context "when calling update" do

		context "when melee move is not valid" do
			it "should return [] if entity1 can not melee attack" do
				manager[infantry].delete MeleeAttackComponent
				result = MeleeSystem.update(manager, infantry, infantry2)
				expect(result).to eq []
			end
	
			it "should also return [] if entity2 is not damageable" do
				manager[infantry2].delete HealthComponent
				result = MeleeSystem.update(manager, infantry, infantry2)
				expect(result).to eq []
			end

			it "should as well return [] if the entities aren't adjacent" do
				manager[infantry2].delete PositionComponent
				manager.add_component(infantry2,
				      PositionComponent.new(0, 0))
				result = MeleeSystem.update(manager, infantry, infantry2)
				expect(result).to eq []
			end
		end

		context "when entity does not have enough energy" do
			it "should return []" do
				manager[infantry][MeleeAttackComponent].first.energy_cost = 100
				manager[infantry][EnergyComponent].first.cur_energy = 0
				result = MeleeSystem.update(manager, infantry, infantry2)
				expect(result).to eq []
			end
		end

		context "when only entity1 attacks" do
			it "should return valid array" do
				manager[infantry2].delete MeleeAttackComponent
				manager[infantry].delete MeleeAttackComponent
				manager.add_component(infantry,
				      MeleeAttackComponent.new(5, 2))
				manager[infantry][EnergyComponent].first.cur_energy = 10
				result = MeleeSystem.update(manager, infantry, infantry2)
				expect(result.size).to eq 1
				expect(result[0][0]).to eq "melee"
				expect(manager[infantry][EnergyComponent].first.cur_energy ).to eq 8
			end
		end

		context "when only entity1 attacks and kills entity2" do
			it "should return valid array" do
				manager[infantry2].delete MeleeAttackComponent
				manager[infantry].delete MeleeAttackComponent
				manager.add_component(infantry,
				      MeleeAttackComponent.new(10, 2))
				manager[infantry][EnergyComponent].first.cur_energy = 10
				result = MeleeSystem.update(manager, infantry, infantry2)
				expect(result.size).to eq 2
				expect(result[0][0]).to eq "melee"
				expect(result[1][0]).to eq "kill"
				expect(manager[infantry][EnergyComponent].first.cur_energy ).to eq 8
			end
		end

		context "when entity1 and entity2 attacks" do
			it "should return valid array" do
				manager[infantry2].delete MeleeAttackComponent
				manager.add_component(infantry2,
				      MeleeAttackComponent.new(5, 2))
				manager[infantry].delete MeleeAttackComponent
				manager.add_component(infantry,
				      MeleeAttackComponent.new(5, 2))
				manager[infantry][EnergyComponent].first.cur_energy = 10
				result = MeleeSystem.update(manager, infantry, infantry2)
				expect(result.size).to eq 2
				expect(result[0][0]).to eq "melee"
				expect(result[1][0]).to eq "melee"
				expect(manager[infantry][EnergyComponent].first.cur_energy ).to eq 8
			end
		end

		context "when entity1 attacks and entity2 kills entity1" do
			it "should return valid array" do
				manager[infantry].delete MeleeAttackComponent
				manager.add_component(infantry,
				      MeleeAttackComponent.new(5, 2))
				result = MeleeSystem.update(manager, infantry, infantry2)
				expect(result.size).to eq 3
				expect(result[0][0]).to eq "melee"
				expect(result[1][0]).to eq "melee"
				expect(result[2][0]).to eq "kill"
			end
		end
	end
end
