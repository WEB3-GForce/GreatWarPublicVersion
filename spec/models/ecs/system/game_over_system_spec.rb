require_relative '../../../spec_helper'

describe GameOverSystem do

    let(:manager)       {EntityManager.new(3, 3)}   

    it "should be a subclass of System" do
        expect(GameOverSystem < System).to be true
    end

    context "when calling update" do
        it "should return nil winner if zero players exist" do
            result = GameOverSystem.update(manager)
            expect(result).to eq ["game_over", nil]
        end

        it "should return winner if one player left" do
            human1 = EntityFactory.human_player(manager, "Jobs")
            result = GameOverSystem.update(manager)
            expect(result).to eq ["game_over", human1]
        end

        it "should return nil if not one player left" do
            human1 = EntityFactory.human_player(manager, "Jobs")
            human2 = EntityFactory.human_player(manager, "Gates")
            result = GameOverSystem.update(manager)
            expect(result).to be nil
        end
    end
end
