require_relative '../../../spec_helper'

describe GameOverSystem do

  let(:manager)       {EntityManager.new(3, 3)}   

  it "should be a subclass of System" do
    expect(GameOverSystem < System).to be true
  end

  context "when calling update" do
    it "should return nil winner if zero players exist" do
      EntityFactory.turn_entity(manager, [])
      result = GameOverSystem.update(manager)
      expect(result).to eq ["game_over", nil]
    end

    it "should return winner if one player left" do
      human1 = EntityFactory.human_player(manager, "Jobs")
      EntityFactory.turn_entity(manager, [human1])
      result = GameOverSystem.update(manager)
      expect(result).to eq ["game_over", human1]
    end

    it "should return nil if not one player left" do
      human1 = EntityFactory.human_player(manager, "Jobs")
      human2 = EntityFactory.human_player(manager, "Gates")
      EntityFactory.turn_entity(manager, [human1, human2])
      result = GameOverSystem.update(manager)
      expect(result).to be nil
    end
  end
end
