require_relative '../../../spec_helper'

describe MotionSystem do

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


	it "should be a subclass of System" do
		expect(MotionSystem < System).to be true
	end

	context "when calling deterimine_locations at the base case" do
	
		it "should terminate if movement < 0" do
		
			MotionSystem.determine_locations(manager, human1,
							 1, 1, -1, result1, [])
			
			expect(result1.empty?).to be true
		end

		it "should terminate if 0 > row" do
		
			MotionSystem.determine_locations(manager, human1,
							 -1, 1, 1, result1, [])
			
			expect(result1.empty?).to be true
		end	

		it "should terminate if row >= manager.row" do
		
			MotionSystem.determine_locations(manager, human1,
							 manager.row, 1, 1, result1, [])
			
			expect(result1.empty?).to be true
		end	

		it "should terminate if 0 > col" do
		
			MotionSystem.determine_locations(manager, human1,
							 1, -1, 1, result1, [])
			
			expect(result1.empty?).to be true
		end	

		it "should terminate if col >= manager.col" do
		
			MotionSystem.determine_locations(manager, human1,
							 1, manager.col, 1, result1, [])
			
			expect(result1.empty?).to be true
		end

	end
	
	context "when calling deterimine_locations with a simple board" do
	
		it "should be able to reach all squares" do
			set_simple()

			MotionSystem.determine_locations(manager, human1,
							 1, 1, 2, result1, []) 
			
			expect(result1.sort).to eq flat_array.sort
		end

		it "should be able to reach only its square" do
			set_simple()

			MotionSystem.determine_locations(manager, human1,
							 1, 1, 0, result1, [])
			
			expect(result1.sort).to eq [flatland11]
		end
	
		it "should be able to reach five square" do
			set_simple()

			MotionSystem.determine_locations(manager, human1,
							 1, 1, 1, result1, [])
			answer = [flatland11, flatland01, flatland10, flatland21, flatland12]
			expect(result1.sort).to eq answer.sort
		end
	
		it "should not contain duplicates" do
			set_simple()

			MotionSystem.determine_locations(manager, human1,
							 1, 1, 10, result1, [])
			expect(result1.sort).to eq flat_array.sort
		end	

		it "should not include or pass over impassable squares" do
			set_simple()
			manager.add_component(flatland01, ImpassableComponent.new)
			MotionSystem.determine_locations(manager, human1,
							 0, 0, 2, result1, [])
			answer = [flatland00, flatland10, flatland20, flatland11]
			expect(result1.sort).to eq answer.sort
		end

		it "should pass over but not include unoccupiable squares" do
			set_simple()
			manager[flatland01].delete OccupiableComponent
			MotionSystem.determine_locations(manager, human1,
							 0, 0, 2, result1, [])
			answer = [flatland00, flatland10, flatland20, flatland11, flatland02]
			expect(result1.sort).to eq answer.sort
		end

		it "should pass over but not include squares occupied by friends" do
			set_simple()
			manager.board[0][1][1].push friend1
			MotionSystem.determine_locations(manager, human1,
							 0, 0, 2, result1, [])
			answer = [flatland00, flatland10, flatland20, flatland11, flatland02]
			expect(result1.sort).to eq answer.sort
		end

		it "should neither pass over nor include squares occupied by only a foe" do
			set_simple()
			manager.board[0][1][1].push foe1
			MotionSystem.determine_locations(manager, human1,
							 0, 0, 2, result1, [])
			answer = [flatland00, flatland10, flatland20, flatland11]
			expect(result1.sort).to eq answer.sort
		end

		it "should neither pass over nor include squares occupied by ay foe" do
			set_simple()
			manager.board[0][1][1].push friend1
			manager.board[0][1][1].push foe1
			MotionSystem.determine_locations(manager, human1,
							 0, 0, 2, result1, [])
			answer = [flatland00, flatland10, flatland20, flatland11]
			expect(result1.sort).to eq answer.sort
		end
	end
	
	context "when calling moveable_locations" do
	
		it "should fail if the entity is not moveable (no PositionComponent)" do
			manager[infantry].delete PositionComponent
			result = MotionSystem.moveable_locations(manager, infantry)
			
			expect(result.empty?).to eq true
		end

		it "should fail if the entity is not moveable (no MotionComponent)" do
			manager[infantry].delete MotionComponent
			result = MotionSystem.moveable_locations(manager, infantry)
			
			expect(result.empty?).to eq true
		end

		it "should properly return the correct squares" do
			set_simple()
			manager.board[1][0][1].push friend1
			manager.board[2][1][1].push foe1
			manager.add_component(flatland12, ImpassableComponent.new)
			manager[flatland01].delete OccupiableComponent
			manager.add_component(infantry, PositionComponent.new(1, 1))

			result = MotionSystem.moveable_locations(manager, infantry)
			answer = [flatland00, flatland02, flatland11, flatland20]
			expect(result.sort).to eq answer.sort
		end

	end

end
