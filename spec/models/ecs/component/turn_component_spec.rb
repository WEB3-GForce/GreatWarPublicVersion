require_relative '../../../spec_helper'

describe TurnComponent do

  let(:player1)      {Entity.new}
  let(:player2)      {Entity.new}
  let(:player3)      {Entity.new}
  let(:player4)      {Entity.new}
  let(:piece1)       {Entity.new}
  let(:piece2)       {Entity.new}
  let(:piece3)       {Entity.new}
  let(:piece4)       {Entity.new}
  let(:basic_turn)   {TurnComponent.new([player1, player2, player3, player4])}

  it "should be a subclass of Component" do
    expect(TurnComponent < Component).to be true
  end

  it "should initialize itself properly" do
    turn_comp = TurnComponent.new([player1, player2, player3, player4])
    expect(turn_comp.players).to eq([player1, player2, player3, player4])
    expect(turn_comp.turn_count).to eq(1)
  end

  it "should keep track of turns" do
    expect(basic_turn.current_turn).to eq(player1)
    expect(basic_turn.turn_count).to eq(1)
  end

  context "when moving to the next turn" do

    it "should properly cycle through each player" do
      expect(basic_turn.next_turn).to eq(player2)
      expect(basic_turn.current_turn).to eq(player2)
      expect(basic_turn.turn_count).to eq(2)
      
      expect(basic_turn.next_turn).to eq(player3)
      expect(basic_turn.current_turn).to eq(player3)
      expect(basic_turn.turn_count).to eq(3)
      
      expect(basic_turn.next_turn).to eq(player4)
      expect(basic_turn.current_turn).to eq(player4)
      expect(basic_turn.turn_count).to eq(4)

      expect(basic_turn.next_turn).to eq(player1)
      expect(basic_turn.current_turn).to eq(player1)
      expect(basic_turn.turn_count).to eq(5)
    end
  end

  it "should have implemented to_s" do
    expect(basic_turn).to respond_to :to_s
    expect(basic_turn.to_s.class).to eq(String)
  end
end
