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
	end

	it "should keep track of turns" do
		expect(basic_turn.current_turn).to eq(player1)
	end

	it "should properly make pieces move" do
		basic_turn.moved(piece1)
		expect(basic_turn.has_moved?(piece1)).to eq(true)
	end

	it "should properly make pieces attack" do
		basic_turn.attacked(piece1)
		expect(basic_turn.has_attacked?(piece1)).to eq(true)
	end

	it "should properly make pieces do special movements" do
		basic_turn.done_special(piece1)
		expect(basic_turn.has_done_special?(piece1)).to eq(true)
	end

	it "should properly keep track of pieces that moved" do
		expect(basic_turn.has_moved?(piece1)).to eq(false)
		basic_turn.moved(piece1)
		expect(basic_turn.has_moved?(piece1)).to eq(true)
	end

	it "should properly keep track of pieces that attacked" do
		expect(basic_turn.has_attacked?(piece1)).to eq(false)
		basic_turn.attacked(piece1)
		expect(basic_turn.has_attacked?(piece1)).to eq(true)
	end

	it "should properly keep track of pieces that did special actions" do
		expect(basic_turn.has_done_special?(piece1)).to eq(false)
		basic_turn.done_special(piece1)
		expect(basic_turn.has_done_special?(piece1)).to eq(true)
	end

	context "when moving to the next turn" do

		it "should properly reset its hashes and change turn" do
			basic_turn.moved(piece1)
			basic_turn.moved(piece2)
			basic_turn.attacked(piece2)
			basic_turn.attacked(piece3)
			basic_turn.done_special(piece1)
			basic_turn.done_special(piece3)
			new_player = basic_turn.next_turn

			expect(new_player).to eq(player2)
			expect(basic_turn.current_turn).to eq(player2)
			expect(basic_turn.has_moved?(piece1)).to eq(false)
			expect(basic_turn.has_moved?(piece2)).to eq(false)
			expect(basic_turn.has_attacked?(piece2)).to eq(false)
			expect(basic_turn.has_attacked?(piece3)).to eq(false)
			expect(basic_turn.has_attacked?(piece1)).to eq(false)
			expect(basic_turn.has_attacked?(piece3)).to eq(false)
		end

		it "should properly cycle through each player" do
			expect(basic_turn.next_turn).to eq(player2)
			expect(basic_turn.current_turn).to eq(player2)
			
			expect(basic_turn.next_turn).to eq(player3)
			expect(basic_turn.current_turn).to eq(player3)
			
			expect(basic_turn.next_turn).to eq(player4)
			expect(basic_turn.current_turn).to eq(player4)

			expect(basic_turn.next_turn).to eq(player1)
			expect(basic_turn.current_turn).to eq(player1)
		end
	end

	it "should have implemented to_s" do
		expect(basic_turn).to respond_to :to_s
		expect(basic_turn.to_s.class).to eq(String)
	end
end
