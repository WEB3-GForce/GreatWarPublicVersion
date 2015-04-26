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

describe RemovePlayerSystem do

    let(:manager)    {EntityManager.new(7, 7)}
    let(:human1)     {EntityFactory.human_player(manager, "David")}
    let(:player2)    {EntityFactory.ai_player(manager, "Goliath")}
    let(:infantry)   {debug_infantry(manager, human1)}
    let(:infantry2)  {debug_infantry(manager, player2)}
    let(:infantry3)  {debug_infantry(manager, player2)}
    let(:bunker1)    {EntityFactory.command_bunker(manager, human1)}
    let(:flatland1)  {EntityFactory.flatland_square(manager)}
    let(:flatland2)  {EntityFactory.flatland_square(manager)}
    let(:flatland3)  {EntityFactory.flatland_square(manager)}
    let(:turn)       {EntityFactory.turn_entity(manager, [human1, player2])}
    let(:row)        {1}
    let(:col)        {1}

    def setup
        manager.add_component(infantry,
                      PositionComponent.new(row, col))
        manager.add_component(bunker1,
                      PositionComponent.new(row+1, col+1))
        manager.add_component(infantry2,
                      PositionComponent.new(row+2, col+2))
        manager.add_component(infantry3,
                      PositionComponent.new(row+2, col+1))    

        manager.add_component(flatland1,
                      PositionComponent.new(row, col))
        manager.add_component(flatland2,
                      PositionComponent.new(row+2, col+2))
        manager.add_component(flatland3,
                      PositionComponent.new(row+2, col+1))
        manager.board[row][col] = [flatland1, [infantry]]
        manager.board[row+2][col+2] = [flatland2, [infantry2]]
        manager.board[row+2][col+1] = [flatland3, [infantry3]]
    end

    def setup_location_in_range
        (0...manager.row).each { |row|
            (0...manager.col).each { |col|
                square = [row, col]
                manager[square].delete PositionComponent
                manager.add_component(square,
                    PositionComponent.new(row, col))
                manager.board[row][col] = [square, []]
            }
        }
    end
    
    before(:each) do
    	setup_location_in_range
        setup()
    end

    it "should be a subclass of System" do
        expect(RemovePlayerSystem < System).to be true
    end
    
   
   context "when calling is_alive?" do
   
   	context "when the player still has a command bunker" do
   		it "should return true" do
   			expect(RemovePlayerSystem.is_alive?(manager, human1)).to be true
   		end
   	end
   
   	context "when the player has no command bunker" do
   		it "should return false" do
   			expect(RemovePlayerSystem.is_alive?(manager, player2)).to be false
   		end
   	end

   end
  
   context "when calling remove_army" do
   	it "should remove only entities belonging to the player." do
		RemovePlayerSystem.remove_army(manager, player2)

   		expect(manager.has_key? infantry2).to be false
   		expect(manager.has_key? infantry3).to be false
   			
   		expect(manager.board[row+2][col+2][1]).to eq([])
       	        expect(manager.board[row+2][col+1][1]).to eq([])
       	        
       	        expect(manager.has_key? infantry).to be true
       	        expect(manager.board[row][col][1]).to eq([infantry])
   	end
   end

   context "when calling remove_player" do
   	it "should remove the specified player" do
   		expect(manager.has_key? turn).to be true
		result = RemovePlayerSystem.remove_player(manager, human1)
		
		expect(result[0]).to eq(["remove_player", [human1]])
		expect(result[1]).to eq(["turn", player2])
		expect(result[2][0]).to eq("game_over")
		
		turn_comp = manager[turn][TurnComponent].first
		expect(turn_comp.players).to eq([player2])
		
		expect(manager.has_key? human1).to be false
		expect(manager.has_key? player2).to be true

   		expect(manager.has_key? infantry2).to be true
   		expect(manager.has_key? infantry3).to be true
   			
   		expect(manager.board[row+2][col+2][1]).to eq([infantry2])
       	        expect(manager.board[row+2][col+1][1]).to eq([infantry3])
       	        
       	        expect(manager.has_key? infantry).to be false
       	        expect(manager.board[row][col][1]).to eq([])
   	end

   	it "should remove the specified player when no turn change" do
   		turn_comp = manager[turn][TurnComponent].first
   		turn_comp.next_turn()
		result = RemovePlayerSystem.remove_player(manager, human1)		
		expect(result[1]).to eq(nil)
   	end

   	it "should remove the specified player when no game over" do
	   	expect(manager.has_key? turn).to be true
   		player3 = EntityFactory.human_player(manager, "Tester")
		result = RemovePlayerSystem.remove_player(manager, human1)		
		expect(result[2]).to eq(nil)
   	end

   end

   context "when calling update" do
   	it "should not remove any players if all are alive" do
   		player2_bunker = EntityFactory.command_bunker(manager,player2)
   		expect(manager.has_key? turn).to be true
		result = RemovePlayerSystem.update(manager)
		
		expect(result).to eq([nil, nil, nil])
		
		turn_comp = manager[turn][TurnComponent].first
		expect(turn_comp.players).to eq([human1, player2])
		
		expect(manager.has_key? human1).to be true
		expect(manager.has_key? player2).to be true

   		expect(manager.has_key? infantry2).to be true
   		expect(manager.has_key? infantry3).to be true
   			
   		expect(manager.board[row+2][col+2][1]).to eq([infantry2])
       	        expect(manager.board[row+2][col+1][1]).to eq([infantry3])
       	        
       	        expect(manager.has_key? infantry).to be true
       	        expect(manager.board[row][col][1]).to eq([infantry])
   	end

   	it "should remove one player that is defeated" do
   		expect(manager.has_key? turn).to be true
		result = RemovePlayerSystem.update(manager)
		
		expect(result[0]).to eq(["remove_player", [player2]])
		expect(result[1]).to eq(nil)
		expect(result[2][0]).to eq("game_over")
		
		turn_comp = manager[turn][TurnComponent].first
		expect(turn_comp.players).to eq([human1])
		
		expect(manager.has_key? human1).to be true
		expect(manager.has_key? player2).to be false

   		expect(manager.has_key? infantry2).to be false
   		expect(manager.has_key? infantry3).to be false
   			
   		expect(manager.board[row+2][col+2][1]).to eq([])
       	        expect(manager.board[row+2][col+1][1]).to eq([])
       	        
       	        expect(manager.has_key? infantry).to be true
       	        expect(manager.board[row][col][1]).to eq([infantry])
   	end

   	it "should remove all players that are dead" do
   		player3 = EntityFactory.human_player(manager, "Tester")
   		expect(manager.has_key? turn).to be true
		result = RemovePlayerSystem.update(manager)
		
		expect(result[0]).to eq(["remove_player", [player3, player2]])
		expect(result[1]).to eq(nil)
		expect(result[2][0]).to eq("game_over")
   	end

   	it "should change the turn appropriately when a player dies" do
	   	player3 = EntityFactory.human_player(manager, "Tester")
   		turn_comp = manager[turn][TurnComponent].first
   		turn_comp.players.push player3
   		turn_comp.next_turn()
   		expect(turn_comp.players).to eq([human1, player2, player3])

		result = RemovePlayerSystem.update(manager)
		
		expect(result[1]).to eq(["turn", human1])
		expect(turn_comp.players).to eq([human1])
   	end

   end
   
end
