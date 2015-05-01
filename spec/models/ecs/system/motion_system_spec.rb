require_relative '../../../spec_helper'

def debug_infantry(entity_manager, owner)
  return EntityFactory.create_entity(entity_manager,
                                     [PieceComponent.infantry,
                                      HealthComponent.new(10),
                                      EnergyComponent.new(10),
                                      MotionComponent.new(5),
                                      MeleeAttackComponent.new(10),
                                      RangeAttackComponent.new(10, 1, 4),
                                      OwnedComponent.new(owner)])
end

describe MotionSystem do

  let(:result1)      {[]}

  let(:manager)           {EntityManager.new(3, 3)}
  let(:human1)            {EntityFactory.human_player(manager, "David")}
  let(:human2)            {EntityFactory.human_player(manager, "Vance")}
  let(:infantry)          {debug_infantry(manager, human1)}
  let(:infantry2)         {debug_infantry(manager, human1)}
  let(:friend1)           {debug_infantry(manager, human1)}
  let(:foe1)              {debug_infantry(manager, human2)}	
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
    manager.add_component(flatland12, ImpassableComponent.new)
    manager[flatland01].delete OccupiableComponent
  end


  it "should be a subclass of System" do
    expect(MotionSystem < System).to be true
  end

  context "when calling on_board?" do	

    it "should return false if 0 > row" do
      result = MotionSystem.on_board?(manager, -1, 1)
      expect(result).to be false
    end	

    it "should return false if row >= manager.row" do
      result = MotionSystem.on_board?(manager, manager.row, 1)
      expect(result).to be false
    end	

    it "should return false if 0 > col" do
      result = MotionSystem.on_board?(manager, 1, -1)
      expect(result).to be false
    end	

    it "should return false if col >= manager.col" do
      result =MotionSystem.on_board?(manager, 1, manager.col)
      expect(result).to be false
    end

    it "should return true for good coordinates" do
      result =MotionSystem.on_board?(manager, 1, 1)
      expect(result).to be true
    end
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


  context "when calling calculate_movement" do

    it "should calculate successfully for terrain with no boosts" do
      set_simple()
      movement = 10
      row = 1
      col = 1
      result = MotionSystem.calculate_movement(manager, movement, row, col)
      expect(result).to eq(movement -1)
    end
    
    it "should calculate successfully for terrain with move_cost boosts" do
      set_simple()
      movement = 10
      row = 1
      col = 1
      manager.board[row][col][0] = hill11
      result = MotionSystem.calculate_movement(manager, movement, row, col)
      expect(result).to eq(movement -2)
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

    it "should pass over and include squares occupied by friends" do
      set_simple()
      manager.board[0][1][1].push friend1
      MotionSystem.determine_locations(manager, human1,
                                       0, 0, 2, result1, [])
      answer = [flatland00, flatland01, flatland10, flatland20, flatland11, flatland02]
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

    it "should neither pass over nor include squares occupied by any foe" do
      set_simple()
      manager.board[0][1][1].push friend1
      manager.board[0][1][1].push foe1
      MotionSystem.determine_locations(manager, human1,
                                       0, 0, 2, result1, [])
      answer = [flatland00, flatland10, flatland20, flatland11]
      expect(result1.sort).to eq answer.sort
    end

    it "should properly return the correct squares with move_boost terrain" do
      set_simple()
      
      # Make sure the infantry can move on flatland
      MotionSystem.determine_locations(manager, human1,
                                       0, 0, 1, result1, [])
      answer = [flatland00, flatland10, flatland01]
      expect(result1.sort).to eq answer.sort
      
      result1 = []
      # However, make sure it can't over terrain
      manager.board[1][0][0] = hill10
      manager.board[0][1][0] = hill01
      MotionSystem.determine_locations(manager, human1,
                                       0, 0, 1, result1, [])
      expect(result1.sort).to eq [flatland00]	
      
      result1 = []
      # However, make sure it can with enough movement
      MotionSystem.determine_locations(manager, human1,
                                       0, 0, 2, result1, [])	
      answer = [flatland00, hill10, hill01]
      expect(result1.sort).to eq answer.sort	
    end


  end

  context "when calling determine_path with a simple board" do

    it "should be able to reach a reachable square" do
      set_intermediate()

      result = MotionSystem.determine_path(manager, human1,
                                           1, 1, 0, 2, 10, [])
      answer = [flatland11, flatland01, flatland02]
      expect(result.map!{|squares| squares[0]}).to eq answer
    end

    it "should be able to reach another reachable square" do
      set_intermediate()
      result = MotionSystem.determine_path(manager, human1,
                                           1, 1, 2, 0, 10, [])
      answer = [flatland11, flatland10, flatland20]
      expect(result.map!{|squares| squares[0]}).to eq answer
    end

    it "should be able to reach a square occupied by an ally" do
      set_intermediate()
      result = MotionSystem.determine_path(manager, human1,
                                           1, 1, 0, 1, 10, [])
      answer = [flatland11, flatland01]
      expect(result.map!{|squares| squares[0]}).to eq answer
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

    it "should properly return the correct squares with move_boost terrain" do
      set_simple()
      
      # Make sure the infantry can move on flatland
      result = MotionSystem.determine_path(manager, human1,
                                           0, 0, 0, 1, 1, [])
      answer = [flatland00, flatland01]
      expect(result.map!{|squares| squares[0]}.sort).to eq answer.sort
      
      # However, make sure it can't over terrain
      manager.board[0][1][0] = hill10
      result = MotionSystem.determine_path(manager, human1,
                                           0, 0, 0, 1, 1, [])
      expect(result.map!{|squares| squares[0]}.sort).to eq []	
      
      # However, make sure it can with enough movement
      result = MotionSystem.determine_path(manager, human1,
                                           0, 0, 0, 1, 2, [])
      answer = [flatland00, hill10]
      expect(result.map!{|squares| squares[0]}.sort).to eq answer.sort	
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
      answer = [flatland00, flatland10, flatland02, flatland20]
      expect(result.sort).to eq answer.sort
    end

    it "should properly return the correct squares with move_boost terrain" do
      set_simple()
      
      # Make sure the infantry can't move onto the hill
      manager.board[1][1][0] = hill11
      manager.add_component(infantry, PositionComponent.new(1, 0))
      manager[infantry][EnergyComponent].first.cur_energy = 1
      result = MotionSystem.moveable_locations(manager, infantry)
      answer = [flatland00, flatland20]
      expect(result.sort).to eq answer.sort
      
      # However, make sure it can move over flatland.
      manager.board[1][1][0] = flatland11
      result = MotionSystem.moveable_locations(manager, infantry)
      answer = [flatland00, flatland11, flatland20]
      expect(result.sort).to eq answer.sort
    end

    it "should properly return more correct squares" do
      set_simple()
      manager.add_component(flatland12, ImpassableComponent.new)
      manager[flatland01].delete OccupiableComponent
      manager.add_component(infantry, PositionComponent.new(1, 1))

      result = MotionSystem.moveable_locations(manager, infantry)
      answer = [flatland00, flatland10, flatland02,
                flatland20, flatland21, flatland22]
      expect(result.sort).to eq answer.sort
    end

    it "should properly return all squares except the current position" do
      set_simple()
      manager.add_component(infantry, PositionComponent.new(1, 1))
      result = MotionSystem.moveable_locations(manager, infantry)

      flat_array.delete(flatland11)
      expect(result.sort).to eq flat_array.sort
    end

    it "should return any squares if an infantry is pinned in" do
      set_simple()
      manager.board[0][1][1].push foe1
      manager.board[1][0][1].push foe1
      manager.board[1][2][1].push foe1
      manager.board[2][1][1].push foe1
      manager.add_component(infantry, PositionComponent.new(1, 1))

      result = MotionSystem.moveable_locations(manager, infantry)
      expect(result.empty?).to be true
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
      set_intermediate()
      manager[infantry].delete MotionComponent
      manager.add_component(infantry, PositionComponent.new(1, 1))
      manager.board[1][1][1].push infantry
      result = MotionSystem.make_move(manager, infantry, "Bad")
      
      expect(result).to eq(nil)
    end

    it "should fail if new_square is already occupied" do
      set_intermediate()
      manager.add_component(infantry, PositionComponent.new(0, 0))
      manager.board[0][0][1].push infantry
      manager.add_component(infantry2, PositionComponent.new(1, 1))
      manager.board[1][1][1].push infantry2
      result = MotionSystem.make_move(manager, infantry, flatland11)
      
      expect(result).to eq(nil)
    end

    it "should fail if there is no path to new_square" do
      set_intermediate()
      manager.add_component(infantry, PositionComponent.new(1, 1))
      manager.board[1][1][1].push infantry
      result = MotionSystem.make_move(manager, infantry, flatland22)
      
      expect(result).to eq(nil)
    end

    it "should fail if the entity doesn't have enough energy to move" do
      set_intermediate()
      manager.add_component(infantry, PositionComponent.new(1, 1))
      manager.board[1][1][1].push infantry
      manager[infantry][EnergyComponent].first.cur_energy = 0
      result = MotionSystem.make_move(manager, infantry, flatland02)
      
      answer = [flatland11, flatland01, flatland02]
      expect(result).to eq(nil)
    end

    it "should properly move to a new square" do
      set_intermediate()
      manager.add_component(infantry, PositionComponent.new(1, 1))
      manager.board[1][1][1].push infantry
      manager[infantry][EnergyComponent].first.cur_energy = 10
      result = MotionSystem.make_move(manager, infantry, flatland02)
      
      answer = [flatland11, flatland01, flatland02]
      expect(result).to eq(answer)
      
      expect(manager.board[1][1][1]).to eq([])
      expect(manager.board[0][2][1]).to eq([infantry])
      
      pos_comp = manager[infantry][PositionComponent].first
      expect(pos_comp.row).to eq(0)
      expect(pos_comp.col).to eq(2)
      
      energy_comp = manager[infantry][EnergyComponent].first
      expect(energy_comp.cur_energy).to eq(8)
    end

    it "should properly move to another new square" do
      set_intermediate()
      manager.add_component(infantry, PositionComponent.new(1, 1))
      manager.board[1][1][1].push infantry
      manager[infantry][EnergyComponent].first.cur_energy = 10
      result = MotionSystem.make_move(manager, infantry, flatland20)
      
      answer = [flatland11, flatland10, flatland20]
      expect(result).to eq(answer)
      
      expect(manager.board[1][1][1]).to eq([])
      expect(manager.board[2][0][1]).to eq([infantry])
      
      pos_comp = manager[infantry][PositionComponent].first
      expect(pos_comp.row).to eq(2)
      expect(pos_comp.col).to eq(0)
      
      energy_comp = manager[infantry][EnergyComponent].first
      expect(energy_comp.cur_energy).to eq(8)
    end

    it "should return nil if the entity tries to moves to where it is standing" do
      set_intermediate()
      manager.add_component(infantry, PositionComponent.new(1, 1))
      manager.board[1][1][1].push infantry
      result = MotionSystem.make_move(manager, infantry, flatland11)
      expect(result).to eq(nil)
    end
  end

  context "when calling remove_piece" do

    it "should fail if the entity is not placed" do
      set_intermediate()
      result = MotionSystem.remove_piece(manager, infantry)
      expect(result).to be false
    end


    it "should fail if the entity is not a piece" do
      set_intermediate()
      result = MotionSystem.remove_piece(manager, flatland00)
      expect(result).to be false
    end


    it "should properly remove the piece" do
      set_intermediate()
      manager.add_component(infantry, PositionComponent.new(1, 1))
      manager.add_component(infantry, PositionComponent.new(2, 2))
      manager.board[1][1][1].push infantry
      result = MotionSystem.remove_piece(manager, infantry)
      
      expect(result).to be true
      
      expect(manager.board[1][1][1]).to eq([])
      
      result = manager[infantry].has_key? PositionComponent 
      expect(result).to be false
    end
  end

  context "when calling adjacent?" do

    it "should return false if entity1 is not placed" do
      set_intermediate()
      manager.add_component(infantry2, PositionComponent.new(2, 2))
      result = MotionSystem.adjacent?(manager, infantry, infantry2)
      expect(result).to be false
    end

    it "should return false if entity2 is not placed" do
      set_intermediate()
      manager.add_component(infantry, PositionComponent.new(2, 2))
      result = MotionSystem.adjacent?(manager, infantry, infantry2)
      expect(result).to be false
    end

    it "should return false if the entities are not adjacent" do
      set_intermediate()
      manager.add_component(infantry, PositionComponent.new(1, 1))
      manager.add_component(infantry2, PositionComponent.new(2, 2))
      result = MotionSystem.adjacent?(manager, infantry, infantry2)
      expect(result).to be false
    end

    it "should return true if the entities are north adjacent" do
      set_intermediate()
      manager.add_component(infantry, PositionComponent.new(1, 1))
      manager.add_component(infantry2, PositionComponent.new(0, 1))
      result = MotionSystem.adjacent?(manager, infantry, infantry2)
      expect(result).to be true
    end

    it "should return true if the entities are south adjacent" do
      set_intermediate()
      manager.add_component(infantry, PositionComponent.new(1, 1))
      manager.add_component(infantry2, PositionComponent.new(2, 1))
      result = MotionSystem.adjacent?(manager, infantry, infantry2)
      expect(result).to be true
    end

    it "should return true if the entities are east adjacent" do
      set_intermediate()
      manager.add_component(infantry, PositionComponent.new(1, 1))
      manager.add_component(infantry2, PositionComponent.new(1, 0))
      result = MotionSystem.adjacent?(manager, infantry, infantry2)
      expect(result).to be true
    end

    it "should return true if the entities are west adjacent" do
      set_intermediate()
      manager.add_component(infantry, PositionComponent.new(1, 1))
      manager.add_component(infantry2, PositionComponent.new(1, 2))
      result = MotionSystem.adjacent?(manager, infantry, infantry2)
      expect(result).to be true
    end
  end

  context "when calling distance" do

    it "should return -1 if entity1 is not placed" do
      set_intermediate()
      manager.add_component(infantry2, PositionComponent.new(2, 2))
      result = MotionSystem.distance(manager, infantry, infantry2)
      expect(result).to be -1
    end

    it "should return -1 if entity2 is not placed" do
      set_intermediate()
      manager.add_component(infantry, PositionComponent.new(2, 2))
      result = MotionSystem.distance(manager, infantry, infantry2)
      expect(result).to be -1
    end

    it "should return 0 if the entities are same position" do
      set_intermediate()
      manager.add_component(infantry, PositionComponent.new(1, 1))
      manager.add_component(infantry2, PositionComponent.new(1, 1))
      result = MotionSystem.distance(manager, infantry, infantry2)
      expect(result).to be 0
    end

    it "should return 1 if the entities are north adjacent" do
      set_intermediate()
      manager.add_component(infantry, PositionComponent.new(1, 1))
      manager.add_component(infantry2, PositionComponent.new(0, 1))
      result = MotionSystem.distance(manager, infantry, infantry2)
      expect(result).to be 1
    end

    it "should return 1 if the entities are south adjacent" do
      set_intermediate()
      manager.add_component(infantry, PositionComponent.new(1, 1))
      manager.add_component(infantry2, PositionComponent.new(2, 1))
      result = MotionSystem.distance(manager, infantry, infantry2)
      expect(result).to be 1
    end

    it "should return 1 if the entities are east adjacent" do
      set_intermediate()
      manager.add_component(infantry, PositionComponent.new(1, 1))
      manager.add_component(infantry2, PositionComponent.new(1, 0))
      result = MotionSystem.distance(manager, infantry, infantry2)
      expect(result).to be 1
    end

    it "should return 1 if the entities are west adjacent" do
      set_intermediate()
      manager.add_component(infantry, PositionComponent.new(1, 1))
      manager.add_component(infantry2, PositionComponent.new(1, 2))
      result = MotionSystem.distance(manager, infantry, infantry2)
      expect(result).to be 1
    end

    it "should return 2 if the entities are diagonally adjacent" do
      set_intermediate()
      manager.add_component(infantry, PositionComponent.new(1, 1))
      manager.add_component(infantry2, PositionComponent.new(2, 2))
      result = MotionSystem.distance(manager, infantry, infantry2)
      expect(result).to be 2
    end

    it "should return 3 if the entities are knight move apart" do
      set_intermediate()
      manager.add_component(infantry, PositionComponent.new(0, 0))
      manager.add_component(infantry2, PositionComponent.new(1, 2))
      result = MotionSystem.distance(manager, infantry, infantry2)
      expect(result).to be 3
    end

    it "should return 4 if the entities are 2 diagonally apart" do
      set_intermediate()
      manager.add_component(infantry, PositionComponent.new(0, 0))
      manager.add_component(infantry2, PositionComponent.new(2, 2))
      result = MotionSystem.distance(manager, infantry, infantry2)
      expect(result).to be 4
    end
  end

end
