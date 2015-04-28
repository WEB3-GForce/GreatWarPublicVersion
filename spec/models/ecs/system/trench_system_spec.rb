require_relative '../../../spec_helper'

describe TrenchSystem do

	let(:result1)      {[]}

	let(:manager)           {EntityManager.new(3, 3)}
	let(:human1)            {EntityFactory.human_player(manager, "David")}
	let(:human2)            {EntityFactory.human_player(manager, "Vance")}
	let(:infantry)          {EntityFactory.infantry(manager, human1)}
	let(:infantry2)         {EntityFactory.infantry(manager, human1)}
	let(:friend1)           {EntityFactory.infantry(manager, human1)}
	let(:foe1)              {EntityFactory.infantry(manager, human2)}	
	let(:flatland00)        {EntityFactory.flatland_square(manager)}
	let(:flatland01)        {EntityFactory.flatland_square(manager)}
	let(:flatland02)        {EntityFactory.flatland_square(manager)}
	let(:flatland10)        {EntityFactory.flatland_square(manager)}
	let(:flatland11)        {EntityFactory.flatland_square(manager)}
	let(:flatland12)        {EntityFactory.flatland_square(manager)}
	let(:flatland20)        {EntityFactory.flatland_square(manager)}
	let(:flatland21)        {EntityFactory.flatland_square(manager)}
	let(:flatland22)        {EntityFactory.flatland_square(manager)}
	let(:hill10)            {EntityFactory.hill_square(manager)}
	let(:hill01)            {EntityFactory.hill_square(manager)}
	let(:hill11)            {EntityFactory.hill_square(manager)}
        let(:flat_array)        {[flatland00, flatland01, flatland02,
		                  flatland10, flatland11, flatland12,
		                  flatland20, flatland21, flatland22]}

	def set_simple
		array = flat_array.dup   
		(0...manager.row).each { |row|
			(0...manager.col).each { |col|
				square = array.shift
				manager.add_component(square,
					PositionComponent.new(row, col))
				manager.board[row][col] = [square, []]
			}
		}             
	end

	
	def set_intermediate
		set_simple()
		manager.board[1][0][1].push friend1
		manager.board[2][1][1].push foe1
	end

	
	context "when calling enough energy" do
		it "should fail if not enough energy" do
			energy_comp = manager.get_components(infantry, EnergyComponent).first
			energy_comp.cur_energy = 0
			expect(TrenchSystem.enough_energy?(manager, infantry)).to eq(false)
		end
	
		it "should succeed if enough energy" do
			expect(TrenchSystem.enough_energy?(manager, infantry)).to eq(true)
		end
	
	end
	
	context "when calling trenchable_location" do
	
		it "should fail for non trench builders" do
			result = TrenchSystem.trenchable_locations(manager, flatland00)
			expect(result).to eq([])
		end

		it "should fail for unplaced entities" do
			result = TrenchSystem.trenchable_locations(manager, infantry)
			expect(result).to eq([])
		end

		it "should fail if not enough energy" do
			energy_comp = manager.get_components(infantry, EnergyComponent).first
			energy_comp.cur_energy = 0
			result = TrenchSystem.trenchable_locations(manager, infantry)
			expect(result).to eq([])
		end

		it "should not fail on out-of-board locations" do
	            manager.add_component(infantry, PositionComponent.new(0,0))
	            TrenchSystem.trenchable_locations(manager, infantry)
	        end

		it "should return correct squares" do
			set_simple
			manager.add_component(infantry, PositionComponent.new(1,1))
           		result = TrenchSystem.trenchable_locations(manager, infantry)
           		answer = [flatland01, flatland10, flatland21, flatland12]
            		expect(result.sort).to eq answer.sort
       		end

		it "should return correct squares when in a corner" do
			set_simple
			manager.add_component(infantry, PositionComponent.new(0,0))
           		result = TrenchSystem.trenchable_locations(manager, infantry)
           		answer = [flatland01, flatland10]
            		expect(result.sort).to eq answer.sort
       		end

		it "should include tiles occupied by friends." do
			set_simple
			manager.board[1][0][1].push friend1
			manager.add_component(infantry, PositionComponent.new(1,1))
           		result = TrenchSystem.trenchable_locations(manager, infantry)
           		answer = [flatland01, flatland10, flatland21, flatland12]
            		expect(result.sort).to eq answer.sort
       		end

		it "should not include tiles occupied by foes." do
			set_simple
			manager.board[1][0][1].push foe1
			manager.add_component(infantry, PositionComponent.new(1,1))
           		result = TrenchSystem.trenchable_locations(manager, infantry)
           		answer = [flatland01, flatland21, flatland12]
            		expect(result.sort).to eq answer.sort
       		end

		it "should not include unmalleable tiles." do
			set_simple
			manager.board[1][0][0] = hill10
			manager.add_component(infantry, PositionComponent.new(1,1))
           		result = TrenchSystem.trenchable_locations(manager, infantry)
           		answer = [flatland01, flatland21, flatland12]
            		expect(result.sort).to eq answer.sort
       		end
	end	

	context "when calling make_trench" do
	
		it "should fail for non trench builders" do
			result = TrenchSystem.make_trench(manager, flatland00, flatland00)
			expect(result).to eq([])
		end

		it "should fail for unplaced entities" do
			result = TrenchSystem.make_trench(manager, infantry, flatland00)
			expect(result).to eq([])
		end

		it "should fail if not enough energy" do
			energy_comp = manager.get_components(infantry, EnergyComponent).first
			energy_comp.cur_energy = 0
			result = TrenchSystem.make_trench(manager, infantry, flatland00)
			expect(result).to eq([])
		end

		it "should succeed if the entity's location is malleable" do
			set_simple
			manager.add_component(infantry, PositionComponent.new(0,0))
			result = TrenchSystem.make_trench(manager, infantry, flatland01)
			expect(result[0][0]).to eq("trench")
			expect(result[0][1]).to eq(infantry)
			
			trench = result[0][2]
			pos_comp = manager.get_components(trench, PositionComponent).first
			expect(pos_comp.row).to eq(0)
			expect(pos_comp.col).to eq(1)
			expect(manager.board[0][1][0]).to eq(trench)
			
			expect(manager.has_key? flatland01).to be false
		end

		it "should decrement energy appropriately on success" do
			set_simple
			trench_comp = manager.get_components(infantry, TrenchBuilderComponent).first
			energy_comp = manager.get_components(infantry, EnergyComponent).first
			original = energy_comp.cur_energy
			manager.add_component(infantry, PositionComponent.new(0,0))
			result = TrenchSystem.make_trench(manager, infantry, flatland01)
			expect(result[0][0]).to eq("trench")
			expect(energy_comp.cur_energy).to eq(original - trench_comp.energy_cost)
		end

		it "should fail if the square is too far away" do
			set_simple
			manager.add_component(infantry, PositionComponent.new(0,0))
			result = TrenchSystem.make_trench(manager, infantry, flatland02)
			expect(result).to eq([])
		end

		it "should fail if the entity's location is not malleable" do
			set_simple
			manager.board[0][1][0] = hill01
			manager.add_component(hill01, PositionComponent.new(0,1))
			manager.add_component(infantry, PositionComponent.new(0,0))
			result = TrenchSystem.make_trench(manager, infantry, hill01)
			expect(result).to eq([])
		end
	end	


	it "should be a subclass of System" do
		expect(TrenchSystem < System).to be true
	end
end
