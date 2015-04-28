require_relative '../../../spec_helper'

def debug_goliath(entity_manager, owner)
    return EntityFactory.create_entity(entity_manager,
                  [PieceComponent.infantry,
                   HealthComponent.new(30),
                   MotionComponent.new(1),
                   MeleeAttackComponent.new(20),
                   EnergyComponent.new(1),
                   OwnedComponent.new(owner)])
end

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

describe RangeSystem do

    let(:manager)    {EntityManager.new(7, 7)}
    let(:human1)     {EntityFactory.human_player(manager, "David")}
    let(:human2)     {EntityFactory.human_player(manager, "Goliath")}
    let(:infantry)   {debug_infantry(manager, human1)}
    let(:infantry2)  {debug_goliath(manager, human2)}
    let(:infantry3)  {debug_infantry(manager, human2)}
    let(:flatland1)  {EntityFactory.flatland_square(manager)}
    let(:flatland2)  {EntityFactory.flatland_square(manager)}
    let(:flatland3)  {EntityFactory.flatland_square(manager)}
    let(:row)        {1}
    let(:col)        {1}

    def setup
        manager.add_component(infantry,
                      PositionComponent.new(row, col))
        manager.add_component(infantry2,
                      PositionComponent.new(row+2, col+2))
    
        manager.add_component(flatland1,
                      PositionComponent.new(row, col))
        manager.add_component(flatland2,
                      PositionComponent.new(row+2, col+2))
        manager.board[row][col] = [flatland1, [infantry]]
        manager.board[row+2][col+2] = [flatland2, [infantry2]]
    end

    def setup_location_in_range
        (0...manager.row).each { |row|
            (0...manager.col).each { |col|
                square = [row, col]
                manager[square].delete PositionComponent
                manager.add_component(square,
                    PositionComponent.new(row, col))
                manager.board[row][col] = [square, []]
            }
        }
    end
    
    before(:each) do
        setup()
    end

    it "should be a subclass of System" do
        expect(RangeSystem < System).to be true
    end

    context "when calling enough_energy?" do
        it "should return true if enough energy" do
            result = RangeSystem.enough_energy?(manager, infantry)
            expect(result).to be true
        end

        it "should return false if not enough energy" do
            manager[infantry][EnergyComponent].first.cur_energy = 0
            result = RangeSystem.enough_energy?(manager, infantry)
            expect(result).to be false
        end
    end

    context "when calling locations_in_range" do

        it "should return correct squares" do
            setup_location_in_range()
            manager[infantry].delete PositionComponent
            manager.add_component(infantry,
                      PositionComponent.new(2, 2))
            result = []
            RangeSystem.locations_in_range(manager, infantry, 1, 3) {
                    |square, occupants|
                result.push(square)
            }
            answer = [       [0,1], [0,2], [0,3],
                      [1,0], [1,1], [1,2], [1,3], [1,4],
                      [2,0], [2,1],        [2,3], [2,4], [2,5],
                      [3,0], [3,1], [3,2], [3,3], [3,4],
                             [4,1], [4,2], [4,3],
                                    [5,2]                      ]
            expect(result.sort).to eq answer.sort
        end

        it "should return correct squares" do
            setup_location_in_range()
            manager[infantry].delete PositionComponent
            manager.add_component(infantry,
                      PositionComponent.new(0, 0))
            result = []
            RangeSystem.locations_in_range(manager, infantry, 1, 3) {
                    |square, occupants|
                result.push(square)
            }
            answer = [       [0,1], [0,2], [0,3],
                      [1,0], [1,1], [1,2],
                      [2,0], [2,1],
                      [3,0]                      ]
            expect(result.sort).to eq answer.sort
        end

        it "should return correct squares" do
            setup_location_in_range()
            manager[infantry].delete PositionComponent
            manager.add_component(infantry,
                      PositionComponent.new(3, 3))
            result = []
            RangeSystem.locations_in_range(manager, infantry, 1, 3) {
                    |square, occupants|
                result.push(square)
            }
             answer = [             [0,3],
                             [1,2], [1,3], [1,4],
                      [2,1], [2,2], [2,3], [2,4], [2,5],
               [3,0], [3,1], [3,2],        [3,4], [3,5], [3,6],
                      [4,1], [4,2], [4,3], [4,4], [4,5],
                             [5,2], [5,3], [5,4],
                                    [6,3]                      ]
            expect(result.sort).to eq answer.sort
        end

    end

    context "when calling in_range?" do

        it "should return false if entity2 is too far from entity1" do
            range = manager[infantry][RangeAttackComponent].first.max_range
            manager[infantry2].delete PositionComponent
            manager.add_component(infantry2,
                      PositionComponent.new(row+range, col+1))
            result = RangeSystem.in_range?(manager, infantry, infantry2)
            expect(result).to be false
        end

        it "should return false if entity2 is too close to entity1" do
            manager[infantry][RangeAttackComponent].first.min_range = 2
            manager[infantry2].delete PositionComponent
            manager.add_component(infantry2,
                      PositionComponent.new(row, col+1))
            result = RangeSystem.in_range?(manager, infantry, infantry2)
            expect(result).to be false
        end

        it "should return true if entity2 is in entity1's range" do
            range = manager[infantry][RangeAttackComponent].first.max_range
            manager[infantry2].delete PositionComponent
            manager.add_component(infantry2,
                      PositionComponent.new(row+range-1, col+1))
            result = RangeSystem.in_range?(manager, infantry, infantry2)
            expect(result).to be true
        end
    end

    context "when calling valid_attack?" do
    
        it "should fail if entity1 is not a range_entity" do
            manager[infantry].delete RangeAttackComponent
            result = RangeSystem.valid_attack?(manager, infantry, infantry2)
            expect(result).to be false
        end

        it "should fail if entity2 is not damageable" do
            manager[infantry2].delete HealthComponent
            result = RangeSystem.valid_attack?(manager, infantry, infantry2)
            expect(result).to be false
        end

        it "should fail if entity2 is range immune" do
            manager[infantry2][RangeAttackImmunityComponent].push RangeAttackImmunityComponent.new
            result = RangeSystem.valid_attack?(manager, infantry, infantry2)
            expect(result).to be false
        end

        it "should fail if the entities are too far apart" do
            manager[infantry2].delete PositionComponent
            manager.add_component(infantry2,
                      PositionComponent.new(row+3, col+3))
            result = RangeSystem.valid_attack?(manager, infantry, infantry2)
            expect(result).to be false
        end

        it "should fail if the entities are too close" do
            manager[infantry][RangeAttackComponent].first.min_range = 2
            manager[infantry2].delete PositionComponent
            manager.add_component(infantry2,
                      PositionComponent.new(row, col+1))
            result = RangeSystem.valid_attack?(manager, infantry, infantry2)
            expect(result).to be false
        end

        it "should return true for valid attack" do
            result = RangeSystem.valid_attack?(manager, infantry, infantry2)
            expect(result).to be true
        end
    end

    context "when calling perform_attack" do
    
        it "should return a [] result from no damage" do
            manager[infantry2].delete HealthComponent
            result = RangeSystem.perform_attack(manager, infantry, infantry2)
            expect(result).to eq []
        end

        it "should return proper array from damage" do
            manager[infantry][RangeAttackComponent].first.attack = 1
            result = RangeSystem.perform_attack(manager, infantry, infantry2)
            expect(result.size).to eq 1
            expect(result[0][0]).to eq "ranged"
        end

        it "should return proper array from damage and kill" do
            manager[infantry][RangeAttackComponent].first.attack = 100
            result = RangeSystem.perform_attack(manager, infantry, infantry2)
            expect(result.size).to eq 2
            expect(result[0][0]).to eq "ranged"
            expect(result[1][0]).to eq "kill"
        end
    end

    context "when calling attackable_locations" do
    
        it "should fail if the entity has no PositionComponent" do
            manager[infantry].delete PositionComponent
            result = RangeSystem.attackable_locations(manager, infantry)
            
            expect(result.empty?).to eq true
        end

        it "should fail if the entity is no RangeAttackComponent" do
            manager[infantry].delete RangeAttackComponent
            result = RangeSystem.attackable_locations(manager, infantry)
            
            expect(result.empty?).to eq true
        end

        it "should return [] if not enough energy remains" do
            manager[infantry][EnergyComponent].first.cur_energy = 0
            result = RangeSystem.attackable_locations(manager, infantry)
            expect(result).to eq []
        end

        it "should not fail on out-of-board locations" do
            manager[infantry].delete PositionComponent
            manager.add_component(infantry, PositionComponent.new(0,0))
            RangeSystem.attackable_locations(manager, infantry)
        end

        it "should return correct square" do
            result = RangeSystem.attackable_locations(manager, infantry)
            answer = [flatland2]
            expect(result).to eq answer
        end

        it "should return multiple correct squares" do
            manager.add_component(infantry3,
                          PositionComponent.new(row+1, col+1))
            manager.add_component(flatland3,
                          PositionComponent.new(row+1, col+1))
            manager.board[row+1][col+1] = [flatland3, [infantry3]]

            result = RangeSystem.attackable_locations(manager, infantry)
            answer = [flatland2, flatland3]
            expect(result.sort).to eq answer.sort
        end

        it "should not return own unit squares" do            
            manager.add_component(infantry3,
                          PositionComponent.new(row+1, col+1))
            manager.add_component(flatland3,
                          PositionComponent.new(row+1, col+1))
            manager.board[row+1][col+1] = [flatland3, [infantry3]]

            manager[infantry3][OwnedComponent].first.owner = human1

            result = RangeSystem.attackable_locations(manager, infantry)
            answer = [flatland2]
            expect(result.sort).to eq answer.sort
        end

        it "should not return too close squares" do            
            manager.add_component(infantry3,
                          PositionComponent.new(row, col+1))
            manager.add_component(flatland3,
                          PositionComponent.new(row, col+1))
            manager.board[row][col+1] = [flatland3, [infantry3]]

            manager[infantry][RangeAttackComponent].first.min_range = 2

            result = RangeSystem.attackable_locations(manager, infantry)
            answer = [flatland2]
            expect(result.sort).to eq answer.sort
        end
    end

    context "when calling attackable_range" do
    
        it "should fail if the entity has no PositionComponent" do
            manager[infantry].delete PositionComponent
            result = RangeSystem.attackable_range(manager, infantry)
            
            expect(result.empty?).to eq true
        end

        it "should fail if the entity is no RangeAttackComponent" do
            manager[infantry].delete RangeAttackComponent
            result = RangeSystem.attackable_range(manager, infantry)
            
            expect(result.empty?).to eq true
        end

        it "should return [] if not enough energy remains" do
            manager[infantry][EnergyComponent].first.cur_energy = 0
            result = RangeSystem.attackable_range(manager, infantry)
            expect(result).to eq []
        end

        it "should not fail on out-of-board locations" do
            manager[infantry].delete PositionComponent
            manager.add_component(infantry, PositionComponent.new(0,0))
            RangeSystem.attackable_range(manager, infantry)
        end

        it "should return correct squares (1)" do
            result = RangeSystem.attackable_range(manager, infantry)
            expect(result.size).to eq 23
        end

        it "should return correct squares (2)" do
            manager.add_component(infantry3,
                          PositionComponent.new(row+1, col+1))
            manager.add_component(flatland3,
                          PositionComponent.new(row+1, col+1))
            manager.board[row+1][col+1] = [flatland3, [infantry3]]

            result = RangeSystem.attackable_range(manager, infantry)
            expect(result.size).to eq 23
        end

        it "should return own unit squares" do            
            manager.add_component(infantry3,
                          PositionComponent.new(row+1, col+1))
            manager.add_component(flatland3,
                          PositionComponent.new(row+1, col+1))
            manager.board[row+1][col+1] = [flatland3, [infantry3]]

            manager[infantry3][OwnedComponent].first.owner = human1

            result = RangeSystem.attackable_range(manager, infantry)
            expect(result.size).to eq 23
        end

        it "should not return too close squares" do            
            manager.add_component(infantry3,
                          PositionComponent.new(row, col+1))
            manager.add_component(flatland3,
                          PositionComponent.new(row, col+1))
            manager.board[row][col+1] = [flatland3, [infantry3]]

            manager[infantry][RangeAttackComponent].first.min_range = 2

            result = RangeSystem.attackable_range(manager, infantry)
            expect(result.size).to eq 19
        end
    end

    context "when calling update" do

        context "when ranged attack is not valid" do
            it "should return [] if entity1 has no ranged attack" do
                manager[infantry].delete RangeAttackComponent
                result = RangeSystem.update(manager, infantry, infantry2)
                expect(result).to eq []
            end
    
            it "should return [] if entity2 is not damageable" do
                manager[infantry2].delete HealthComponent
                result = RangeSystem.update(manager, infantry, infantry2)
                expect(result).to eq []
            end

            it "should return [] if the entities too far" do
                manager[infantry2].delete PositionComponent
                manager.add_component(infantry2,
                        PositionComponent.new(row+3, col+3))
                result = RangeSystem.update(manager, infantry, infantry2)
                expect(result).to eq []
            end

            it "should return [] if the entities too close" do
                manager[infantry][RangeAttackComponent].first.min_range = 2
                manager[infantry2].delete PositionComponent
                manager.add_component(infantry2,
                        PositionComponent.new(row, col+1))
                result = RangeSystem.update(manager, infantry, infantry2)
                expect(result).to eq []
            end

            it "should return [] if not enough energy remains" do
                    manager[infantry][EnergyComponent].first.cur_energy = 0
                    result = RangeSystem.update(manager, infantry, infantry2)
                    expect(result).to eq []
            end
        end

        context "when attacking without splash damage" do

            context "when entity1 attacks w/o killing entity2" do
                it "should return valid array" do
                    manager[infantry][EnergyComponent].first.cur_energy = 10
                    manager[infantry][RangeAttackComponent].first.attack = 1
                    result = RangeSystem.update(manager, infantry, infantry2)
                    expect(result.size).to eq 1
                    expect(result[0][0]).to eq "ranged"
                    expect(manager[infantry][EnergyComponent].first.cur_energy).to eq(
                    	10 - manager[infantry][RangeAttackComponent].first.energy_cost)
                end
            end

            context "when entity1 attacks and kills entity2" do
                it "should return valid array" do
                    manager[infantry][EnergyComponent].first.cur_energy = 10
                    manager[infantry][RangeAttackComponent].first.attack = 100
                    result = RangeSystem.update(manager, infantry, infantry2)
                    expect(result.size).to eq 2
                    expect(result[0][0]).to eq "ranged"
                    expect(result[1][0]).to eq "kill"
                    expect(manager[infantry][EnergyComponent].first.cur_energy).to eq(
                    	10 - manager[infantry][RangeAttackComponent].first.energy_cost)
                end
            end

        end

        context "when attacking with splash damage" do

            context "when entity1 attacks w/o killing entity2" do
                it "should return valid array" do
                    manager[infantry][EnergyComponent].first.cur_energy = 10
                    manager[infantry][RangeAttackComponent].first.attack = 1
                    manager[infantry][RangeAttackComponent].first.splash << 1.0
                    manager.add_component(infantry3,
                          PositionComponent.new(row+1, col+2))
                    manager.add_component(flatland3,
                          PositionComponent.new(row+1, col+2))
                    manager.board[row+1][col+2] = [flatland3, [infantry3]]
                    result = RangeSystem.update(manager, infantry, infantry2)
                    expect(result.size).to eq 2
                    expect(result[0].size).to eq 7
                    expect(result[0][0]).to eq "ranged"
                    expect(result[1][0]).to eq "ranged"
                    expect(manager[infantry][EnergyComponent].first.cur_energy).to eq(
                    	10 - manager[infantry][RangeAttackComponent].first.energy_cost)
                end

                it "should not hurt friendly units" do
                    manager[infantry][EnergyComponent].first.cur_energy = 10
                    manager[infantry][RangeAttackComponent].first.attack = 1
                    manager[infantry][RangeAttackComponent].first.splash << 1.0
                    manager.add_component(infantry3,
                          PositionComponent.new(row+1, col+2))
                    manager.add_component(flatland3,
                          PositionComponent.new(row+1, col+2))
                    manager.board[row+1][col+2] = [flatland3, [infantry3]]
                    manager[infantry3][OwnedComponent].first.owner = human1
                    result = RangeSystem.update(manager, infantry, infantry2)
                    expect(result.size).to eq 2
                    expect(result[0].size).to eq 7
                    expect(result[0][0]).to eq "ranged"
                    expect(result[1][0]).to eq "ranged"
                    expect(manager[infantry][EnergyComponent].first.cur_energy).to eq(
                    	10 - manager[infantry][RangeAttackComponent].first.energy_cost)
                end
            end

            context "when entity1 attacks and kills entity2" do
                it "should return valid array" do
                    manager[infantry][EnergyComponent].first.cur_energy = 10
                    manager[infantry][RangeAttackComponent].first.attack = 100
                    manager[infantry][RangeAttackComponent].first.splash << 1.0
                    manager.add_component(infantry3,
                          PositionComponent.new(row+1, col+2))
                    manager.add_component(flatland3,
                          PositionComponent.new(row+1, col+2))
                    manager.board[row+1][col+2] = [flatland3, [infantry3]]
                    result = RangeSystem.update(manager, infantry, infantry2)
                    expect(result.size).to eq 4
                    expect(result[0][0]).to eq "ranged"
                    expect(result[0].size).to eq 7
                    expect(result[1][0]).to eq "kill"
                    expect(result[2][0]).to eq "ranged"
                    expect(result[3][0]).to eq "kill"
                    expect(manager[infantry][EnergyComponent].first.cur_energy).to eq(
                    	10 - manager[infantry][RangeAttackComponent].first.energy_cost)
                end

                it "should hurt friendly units" do
                    manager[infantry][EnergyComponent].first.cur_energy = 10
                    manager[infantry][RangeAttackComponent].first.attack = 100
                    manager[infantry][RangeAttackComponent].first.splash << 1.0
                    manager.add_component(infantry3,
                          PositionComponent.new(row+1, col+2))
                    manager.add_component(flatland3,
                          PositionComponent.new(row+1, col+2))
                    manager.board[row+1][col+2] = [flatland3, [infantry3]]
                    manager[infantry3][OwnedComponent].first.owner = human1
                    result = RangeSystem.update(manager, infantry, infantry2)
                    expect(result.size).to eq 4
                    expect(result[0][0]).to eq "ranged"
                    expect(result[0].size).to eq 7
                    expect(result[1][0]).to eq "kill"
                    expect(result[2][0]).to eq "ranged"
                    expect(result[3][0]).to eq "kill"
                    expect(manager[infantry][EnergyComponent].first.cur_energy).to eq(
                    	10 - manager[infantry][RangeAttackComponent].first.energy_cost)
                end
            end
            
        end
    end
end
