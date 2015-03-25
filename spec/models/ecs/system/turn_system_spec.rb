require_relative '../../../spec_helper'

describe TurnSystem do

    let(:manager)       {EntityManager.new(3, 3)}
    let(:human1)        {EntityFactory.human_player(manager, "Gates")}    
    let(:human2)        {EntityFactory.human_player(manager, "Jobs")}
    let(:infantry1a)    {EntityFactory.infantry(manager, human1)}    
    let(:infantry1b)    {EntityFactory.infantry(manager, human1)}
    let(:infantry2a)    {EntityFactory.infantry(manager, human2)}
    let(:infantry2b)    {EntityFactory.infantry(manager, human2)}
    let(:turn_entity)   {EntityFactory.turn_entity(manager, [human1, human2])}

	it "should be a subclass of System" do
		expect(TurnSystem < System).to be true
	end

    context "when calling turn_component" do
        it "should return the entity manager's turn component" do
            result = TurnSystem.turn_component(manager)
            expect(result).to be EntityManager[turn_entity][TurnComponent].first
        end
    end

    context "when calling current_turn" do
        it "should return the current player's turn" do
            result = TurnSystem.current_turn(manager)
            expect(result).to be human1
        end
    end

    context "when calling next_turn" do
        it "should return the next player's turn" do
            result = TurnSystem.next_turn(manager)
            expect(result).to be human2
        end
    end

    context "when calling current_turn_entity?" do
        it "should return true if entity belongs to current player" do
            result = TurnSystem.current_turn_entity?(manager, infantry1a)
            expect(result).to be true
        end

        it "should return false if entity doesn't belong to current player" do
            result = TurnSystem.current_turn_entity?(manager, infantry2a)
            expect(result).to be false
        end
    end

    context "when calling current_turn_entities_each" do
        it "should return entities belonging to the current player" do
            TurnSystem.current_turn_entities_each(manager) { |e|
                owner = EntityManager[e][OwnedComponent].first.owner
                expect(owner).to be human1
            }
        end
    end

    context "when calling current_turn_entities_each" do
        it "should return all entities belonging to the current player" do
            result = TurnSystem.current_turn_entities(manager)
            expect(result.to_set).to be [infantry1a, infantry2a].to_set
        end
    end

    context "when calling update" do 
        it "should change the current player to the next" do
            result = TurnSystem.update(manager)
            expect(result).to be ["turn", human2]

            turn = EntityManager[turn_entity][TurnComponent].first.current_turn
            expect(turn).to be human2
        end

        it "should replenish entity energies for current player" do
        end

        it "should not change entity energies of other players" do
        end
    end
end
