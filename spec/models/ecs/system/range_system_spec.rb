require_relative '../../../spec_helper'

describe RangeSystem do

    let(:manager)    {EntityManager.new(6, 6)}
    let(:human1)     {EntityFactory.human_player(manager, "David")}
    let(:human2)     {EntityFactory.human_player(manager, "Goliath")}
    let(:infantry)   {EntityFactory.infantry(manager, human1)}
    let(:infantry2)  {EntityFactory.goliath(manager, human2)}
    let(:infantry3)  {EntityFactory.infantry(manager, human2)}
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
    
    before(:each) do
        setup()
    end

    it "should be a subclass of System" do
        expect(RangeSystem < System).to be true
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
            expect(result[0][0]).to eq "range"
        end

        it "should return proper array from damage and kill" do
            manager[infantry][RangeAttackComponent].first.attack = 100
            result = RangeSystem.perform_attack(manager, infantry, infantry2)
            expect(result.size).to eq 2
            expect(result[0][0]).to eq "range"
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
        end

        context "when entity1 attacks w/o killing entity2" do
            it "should return valid array" do
                manager[infantry][RangeAttackComponent].first.attack = 1
                result = RangeSystem.update(manager, infantry, infantry2)
                expect(result.size).to eq 1
                expect(result[0][0]).to eq "range"
            end
        end

        context "when entity1 attacks and kills entity2" do
            it "should return valid array" do
                manager[infantry][RangeAttackComponent].first.attack = 100
                result = RangeSystem.update(manager, infantry, infantry2)
                expect(result.size).to eq 2
                expect(result[0][0]).to eq "range"
                expect(result[1][0]).to eq "kill"
            end
        end
    end
end
