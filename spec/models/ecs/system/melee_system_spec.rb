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

describe MeleeSystem do

	let(:manager)    {EntityManager.new(3, 3)}
	let(:human1)     {EntityFactory.human_player(manager, "David")}
    let(:human2)     {EntityFactory.human_player(manager, "Goliath")}
	let(:infantry)   {debug_infantry(manager, human1)}
	let(:infantry2)  {debug_infantry(manager, human2)}
	let(:infantry3)  {debug_infantry(manager, human2)}
	let(:flatland1)   {EntityFactory.flatland_square(manager)}
	let(:flatland2)   {EntityFactory.flatland_square(manager)}
	let(:flatland3)   {EntityFactory.flatland_square(manager)}
	let(:row)        {1}
	let(:col)        {1}

	def setup
		manager.add_component(infantry,
				      PositionComponent.new(row, col))
		manager.add_component(infantry2,
				      PositionComponent.new(row+1, col))
	
		manager.add_component(flatland1,
				      PositionComponent.new(row, col))
		manager.add_component(flatland2,
				      PositionComponent.new(row+1, col))
		manager.board[row][col] = [flatland1, [infantry]]
		manager.board[row+1][col] = [flatland2, [infantry2]]
	end
	
	before(:each) do
		setup()
	end

	it "should be a subclass of System" do
		expect(MeleeSystem < System).to be true
	end

    context "when calling enough_energy?" do
        it "should return true if enough energy" do
            result = MeleeSystem.enough_energy?(manager, infantry)
            expect(result).to be true
        end

        it "should return false if not enough energy" do
            manager[infantry][EnergyComponent].first.cur_energy = 0
            result = MeleeSystem.enough_energy?(manager, infantry)
            expect(result).to be false
        end
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

	context "when calling attackable_locations" do
    
        it "should fail if the entity has no PositionComponent" do
            manager[infantry].delete PositionComponent
            result = MeleeSystem.attackable_locations(manager, infantry)
            
            expect(result.empty?).to eq true
        end

        it "should fail if the entity is no MeleeAttackComponent" do
            manager[infantry].delete MeleeAttackComponent
            result = MeleeSystem.attackable_locations(manager, infantry)
            
            expect(result.empty?).to eq true
        end

        it "should return [] if not enough energy remains" do
            manager[infantry][EnergyComponent].first.cur_energy = 0
            result = MeleeSystem.attackable_locations(manager, infantry)
            expect(result).to eq []
        end

        it "should not fail on out-of-board locations" do
            manager[infantry].delete PositionComponent
            manager.add_component(infantry, PositionComponent.new(0,0))
            MeleeSystem.attackable_locations(manager, infantry)
        end

        it "should return correct square" do
            result = MeleeSystem.attackable_locations(manager, infantry)
            answer = [flatland2]
            expect(result).to eq answer
        end

        it "should return multiple correct squares" do
            manager.add_component(infantry3,
                          PositionComponent.new(row, col+1))
            manager.add_component(flatland3,
                          PositionComponent.new(row, col+1))
            manager.board[row][col+1] = [flatland3, [infantry3]]

            result = MeleeSystem.attackable_locations(manager, infantry)
            answer = [flatland2, flatland3]
            expect(result.sort).to eq answer.sort
        end

        it "should not return own unit squares" do            
            manager.add_component(infantry3,
                          PositionComponent.new(row, col+1))
            manager.add_component(flatland3,
                          PositionComponent.new(row, col+1))
            manager.board[row][col+1] = [flatland3, [infantry3]]

            manager[infantry3][OwnedComponent].first.owner = human1

            result = MeleeSystem.attackable_locations(manager, infantry)
            answer = [flatland2]
            expect(result.sort).to eq answer.sort
        end
    end

    context "when calling attackable_range" do
    
        it "should fail if the entity has no PositionComponent" do
            manager[infantry].delete PositionComponent
            result = MeleeSystem.attackable_range(manager, infantry)
            
            expect(result.empty?).to eq true
        end

        it "should fail if the entity is no MeleeAttackComponent" do
            manager[infantry].delete MeleeAttackComponent
            result = MeleeSystem.attackable_range(manager, infantry)
            
            expect(result.empty?).to eq true
        end

        it "should return [] if not enough energy remains" do
            manager[infantry][EnergyComponent].first.cur_energy = 0
            result = MeleeSystem.attackable_range(manager, infantry)
            expect(result).to eq []
        end

        it "should not fail on out-of-board locations" do
            manager[infantry].delete PositionComponent
            manager.add_component(infantry, PositionComponent.new(0,0))
            MeleeSystem.attackable_range(manager, infantry)
        end

        it "should return correct squares (1)" do
            result = MeleeSystem.attackable_range(manager, infantry)
            expect(result.size).to eq 4
        end

        it "should return correct squares (2)" do
            manager.add_component(infantry3,
                          PositionComponent.new(row+1, col+1))
            manager.add_component(flatland3,
                          PositionComponent.new(row+1, col+1))
            manager.board[row+1][col+1] = [flatland3, [infantry3]]

            result = MeleeSystem.attackable_range(manager, infantry)
            expect(result.size).to eq 4
        end

        it "should return multiple correct squares" do
            manager.add_component(infantry3,
                          PositionComponent.new(row, col+1))
            manager.add_component(flatland3,
                          PositionComponent.new(row, col+1))
            manager.board[row][col+1] = [flatland3, [infantry3]]

            result = MeleeSystem.attackable_range(manager, infantry)
            expect(result.size).to eq 4
        end

        it "should return unit squares" do            
            manager.add_component(infantry3,
                          PositionComponent.new(row, col+1))
            manager.add_component(flatland3,
                          PositionComponent.new(row, col+1))
            manager.board[row][col+1] = [flatland3, [infantry3]]

            manager[infantry3][OwnedComponent].first.owner = human1

            result = MeleeSystem.attackable_range(manager, infantry)
            expect(result.size).to eq 4
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
