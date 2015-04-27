require_relative '../../../spec_helper'

describe TrenchSystem do

	let(:manager)           {EntityManager.new(3, 3)}
	let(:human1)            {EntityFactory.human_player(manager, "David")}
	let(:infantry)          {EntityFactory.infantry(manager, human1)}	
	let(:flatland)        {EntityFactory.flatland_square(manager)}
	let(:hill)            {EntityFactory.hill_square(manager)}
	let(:row)		{0}
	let(:col)		{1}

	def set_simple
		manager.add_component(infantry, PositionComponent.new(row, col))
		manager.add_component(flatland, PositionComponent.new(row, col))
		manager.board[row][col] = [flatland, [infantry]]
	end
	
	context "when calling trenchable_location" do
	
		it "should fail for non trench builders" do
			manager.add_component(flatland, PositionComponent.new(row, col))
			result = TrenchSystem.trenchable_locations(manager, flatland)
			expect(result).to be(nil)
		end

		it "should fail for unplaced entities" do
			result = TrenchSystem.trenchable_locations(manager, infantry)
			expect(result).to be(nil)
		end

		it "should succeed if the entity's location is malleable" do
			set_simple
			result = TrenchSystem.trenchable_locations(manager, infantry)
			expect(result).to eq([flatland])
		end

		it "should fail if the entity's location is not malleable" do
			set_simple
			manager.board[row][col][0] = hill
			result = TrenchSystem.trenchable_locations(manager, infantry)
			expect(result).to eq(nil)
		end
	end	

	context "when calling make_trench" do
	
		it "should fail for non trench builders" do
			manager.add_component(flatland, PositionComponent.new(row, col))
			result = TrenchSystem.make_trench(manager, flatland)
			expect(result).to be(nil)
		end

		it "should fail for unplaced entities" do
			result = TrenchSystem.make_trench(manager, infantry)
			expect(result).to be(nil)
		end

		it "should succeed if the entity's location is malleable" do
			set_simple
			result = TrenchSystem.make_trench(manager, infantry)
			expect(result[0]).to eq("trench")
			
			trench = result[1]
			pos_comp = manager.get_components(trench, PositionComponent).first
			expect(pos_comp.row).to eq(row)
			expect(pos_comp.col).to eq(col)
			expect(manager.board[row][col][0]).to eq(trench)
			
			expect(manager.has_key? flatland).to be false
		end

		it "should fail if the entity's location is not malleable" do
			set_simple
			manager.board[row][col][0] = hill
			result = TrenchSystem.make_trench(manager, infantry)
			expect(result).to eq(nil)
		end
	end	


	it "should be a subclass of System" do
		expect(TrenchSystem < System).to be true
	end
end
