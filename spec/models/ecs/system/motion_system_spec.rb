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

	
	def set_intermediate
		set_simple()
		manager.board[1][0][1].push friend1
		manager.board[2][1][1].push foe1
		manager.add_component(flatland12, ImpassableComponent.new)
		manager[flatland01].delete OccupiableComponent
	end


	it "should be a subclass of System" do
		expect(MotionSystem < System).to be true
	end

	context "when calling valid_move?" do
	
		it "should accept a valid move" do
			result = MotionSystem.valid_move?(manager, 1, 1, 1)
			expect(result).to be true
		end
	
		it "should terminate if movement < 0" do
			result = MotionSystem.valid_move?(manager, 1, 1, -1)
			expect(result).to be false
		end

		it "should terminate if 0 > row" do
			result = MotionSystem.valid_move?(manager, -1, 1, 1)
			expect(result).to be false
		end	

		it "should terminate if row >= manager.row" do
		
			result = MotionSystem.valid_move?(manager, manager.row,
							  1, 1)
			expect(result).to be false
		end	

		it "should terminate if 0 > col" do
		
			result = MotionSystem.valid_move?(manager, 1, -1, 1)
			expect(result).to be false
		end	

		it "should terminate if col >= manager.col" do
		
			result =MotionSystem.valid_move?(manager, 1, manager.col, 1)
			expect(result).to be false
		end

	end

	context "when calling pass_over_square?" do

		it "should be able to pass over an unoccupied passable square" do
			set_simple()
			manager[flatland01].delete OccupiableComponent
			result = MotionSystem.pass_over_square?(manager, flatland01,
							 [], human1)
			expect(result).to eq true
		end

		it "should not be able to pass over an impassable squares" do
			set_simple()
			manager.add_component(flatland01, ImpassableComponent.new)
			result = MotionSystem.pass_over_square?(manager, flatland01,
							 [], human1)
			expect(result).to eq false
		end

		it "should be able to pass over squares occupied by friends" do
			set_simple()
			result = MotionSystem.pass_over_square?(manager, flatland01,
							 [friend1], human1)
			expect(result).to eq true
		end

		it "should be able to pass over squares occupied by a foe" do
			set_simple()
			result = MotionSystem.pass_over_square?(manager, flatland01,
							 [foe1], human1)
			expect(result).to eq false
		end


		it "should be able to pass over squares occupied by any foe" do
			set_simple()
			result = MotionSystem.pass_over_square?(manager, flatland01,
							 [friend1, foe1], human1)
			expect(result).to eq false
		end
	end

	context "when calling occupy_square?" do

		it "should be able to occupy an unoccupied occupiable square" do
			set_simple()
			result = MotionSystem.occupy_square?(manager, flatland01,
							    [])
			expect(result).to eq true
		end

		it "should not be able to occupy an unoccupiable square" do
			set_simple()
			manager[flatland01].delete OccupiableComponent
			result = MotionSystem.occupy_square?(manager, flatland01,
							    [])
			expect(result).to eq false
		end

		it "should not be able to occupy an occupied square" do
			set_simple()
			manager[flatland01].delete OccupiableComponent
			result = MotionSystem.occupy_square?(manager, flatland01,
							    [friend1])
			expect(result).to eq false
		end
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

	context "when calling determine_path with a simple board" do

		it "should be able to reach a reachable square" do
			set_intermediate()

			result = MotionSystem.determine_path(manager, human1,
			                                     1, 1, 0, 2, 10, [])
			answer = [flatland11, flatland01, flatland02]
			expect(result).to eq answer
		end

		it "should be able to reach another reachable square" do
			set_intermediate()
			result = MotionSystem.determine_path(manager, human1,
			                                     1, 1, 2, 0, 10, [])
			answer = [flatland11, flatland10, flatland20]
			expect(result).to eq answer
		end

		it "should be able to reach a square occupied by an ally" do
			set_intermediate()
			result = MotionSystem.determine_path(manager, human1,
			                                     1, 1, 0, 1, 10, [])
			answer = [flatland11, flatland01]
			expect(result).to eq answer
		end

		it "should not be able to reach squares beyond its range" do
			set_intermediate()

			result = MotionSystem.determine_path(manager, human1,
			                                     1, 1, 0, 2, 1, [])
			expect(result).to eq []
		end	

		it "should not be able to reach unreachable squares" do
			set_intermediate()
			result = MotionSystem.determine_path(manager, human1,
			                                     1, 1, 2, 2, 10, [])
			expect(result).to eq []
		end

		it "should not be able to reach an enemy square" do
			set_intermediate()
			result = MotionSystem.determine_path(manager, human1,
			                                     1, 1, 1, 2, 10, [])
			expect(result).to eq []
		end
	end

	context "when calling move_entity" do

		it "should properly move an entity to another new square" do
			set_intermediate()
			start_pos = PositionComponent.new(1, 1)
			manager.add_component(infantry, start_pos)
			
			end_pos = manager.get_components(flatland20, PositionComponent).first
			
			MotionSystem.move_entity(manager, infantry, start_pos, end_pos)
						
			expect(manager.board[1][1][1]).to eq([])
			expect(manager.board[2][0][1]).to eq([infantry])
			
			pos_comp = manager[infantry][PositionComponent].first
			expect(pos_comp.row).to eq(2)
			expect(pos_comp.col).to eq(0)
		end
	end

	context "when calling moveable_locations" do
	
		it "should fail if the entity is not moveable (no PositionComponent)" do
			result = MotionSystem.moveable_locations(manager, infantry)
			
			expect(result.empty?).to eq true
		end

		it "should fail if the entity is not moveable (no MotionComponent)" do
			manager[infantry].delete MotionComponent
			manager.add_component(infantry, PositionComponent.new(1, 1))
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

	context "when calling make_move" do
	
		it "should fail if the entity is not moveable (no PositionComponent)" do
			result = MotionSystem.make_move(manager, infantry, flatland00)
			expect(result).to eq(nil)
		end

		it "should fail if the entity is not moveable (no MotionComponent)" do
			manager[infantry].delete MotionComponent
			manager.add_component(infantry, PositionComponent.new(1, 1))
			result = MotionSystem.make_move(manager, infantry, flatland00)
			
			expect(result).to eq(nil)
		end


		it "should fail if new_square is not a board square" do
			manager[infantry].delete MotionComponent
			manager.add_component(infantry, PositionComponent.new(1, 1))
			result = MotionSystem.make_move(manager, infantry, "Bad")
			
			expect(result).to eq(nil)
		end

		it "should fail if new_square is already occupied" do
			set_intermediate()
			manager.add_component(infantry, PositionComponent.new(0, 0))
			manager.add_component(infantry2, PositionComponent.new(1, 1))
			manager.board[1][1][1].push infantry2
			result = MotionSystem.make_move(manager, infantry, flatland11)
			
			expect(result).to eq(nil)
		end

		it "should fail if there is no path to new_square" do
			set_intermediate()
			manager.add_component(infantry, PositionComponent.new(1, 1))
			result = MotionSystem.make_move(manager, infantry, flatland22)
			
			expect(result).to eq(nil)
		end


		it "should properly move to a new square" do
			set_intermediate()
			manager.add_component(infantry, PositionComponent.new(1, 1))
			result = MotionSystem.make_move(manager, infantry, flatland02)
			
			answer = [flatland11, flatland01, flatland02]
			expect(result).to eq(answer)
			
			expect(manager.board[1][1][1]).to eq([])
			expect(manager.board[0][2][1]).to eq([infantry])
			
			pos_comp = manager[infantry][PositionComponent].first
			expect(pos_comp.row).to eq(0)
			expect(pos_comp.col).to eq(2)
		end

		it "should properly move to another new square" do
			set_intermediate()
			manager.add_component(infantry, PositionComponent.new(1, 1))
			result = MotionSystem.make_move(manager, infantry, flatland20)
			
			answer = [flatland11, flatland10, flatland20]
			expect(result).to eq(answer)
			
			expect(manager.board[1][1][1]).to eq([])
			expect(manager.board[2][0][1]).to eq([infantry])
			
			pos_comp = manager[infantry][PositionComponent].first
			expect(pos_comp.row).to eq(2)
			expect(pos_comp.col).to eq(0)
		end
	end
end
