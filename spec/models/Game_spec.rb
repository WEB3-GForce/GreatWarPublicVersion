require_relative '../spec_helper.rb'

describe Game do
    let(:manager)  {EntityManager.new(10, 10)}
    let(:users)    {[OpenStruct.new({name: "1", id: 1, channel: "N/A 1"}),
                     OpenStruct.new({name: "2", id: 2, channel: "N/A 2"}),]}

    before(:each) do
        @players, @turn, @pieces = EntityFactory.create_game_basic(manager, users)
    end

    context "calling init_game" do
        it "should create a default game if no path provided" do
            manager = Game.init_game(users)
            expect(manager).to_not be nil
        end

        it "should create a game from JSON if path provided" do
            manager = Game.init_game(users, File.dirname(__FILE__)+'/demo.json')
            expect(manager).to_not be nil
        end
    end

    context "calling get_user_channels" do
        it "should get an array of the channels" do 
            result = Game.get_user_channels(manager)
            expect(result.sort).to eq ["N/A 1", "N/A 2"].sort
        end
    end

    context "calling extract_coord" do
        it "should get the coordinates translated correctly" do 
            location = { 'x' => 1, 'y' => 2 }
            result = Game.extract_coord(location)
            expect(result).to eq [2, 1]
        end
    end

    context "calling verify_owner" do
        it "should work" do
            result = Game.verify_owner(1, manager, @pieces[0])
            expect(result).to_not be nil
        end

        it "should return true if entity is owned by the requester" do
        end

        it "should return false if entity is not owned by requester" do
        end
    end

    context "calling verify_turn" do
        it "should work" do
            result = Game.verify_turn(1, manager)
            expect(result).to_not be nil
        end

        it "should return true if it is the requester's turn" do 
        end

        it "should return false if it is not the requester's turn" do
        end
    end

    context "calling get_game_state" do
        it "should work" do
            result = Game.get_game_state(1, manager)
            expect(result).to_not be nil
        end

        it "should return a hash representing the game state" do 
        end
    end

    context "calling get_player_id" do
        it "should work" do
            result = Game.get_game_state(1, manager)
            expect(result).to_not be nil
        end

        it "should return the entity idea of the requester" do 
        end
    end
    
    context "calling get_unit_actions" do
        it "should work" do
            result = Game.get_unit_actions(1, manager, @pieces[0])
            expect(result).to_not be nil
        end

        it "should return an RPC for displaying unit actions" do 
        end
    end

    context "calling get_unit_moves" do
        it "should work" do
            result = Game.get_unit_moves(1, manager, @pieces[0])
            expect(result).to_not be nil
        end
        
        it "should return an RPC for highlighting squares the entity can move to" do 
        end
    end

    context "calling get_unit_melee_attacks" do
        it "should work" do
            result = Game.get_unit_melee_attacks(1, manager, @pieces[0])
            expect(result).to_not be nil
        end

        it "should return an RPC for highlighting squares the entity can melee attack" do 
        end
    end
    
    context "calling get_unit_ranged_attacks" do
        it "should work" do
            result = Game.get_unit_ranged_attacks(1, manager, @pieces[0])
            expect(result).to_not be nil
        end

        it "should return an RPC for highlighting squares the entity can range attack" do 
        end
    end

    context "calling get_unit_trench_locations" do
        it "should work" do
            result = Game.get_unit_trench_locations(1, manager, @pieces[0])
            expect(result).to_not be nil
        end

        it "should return an RPC for highlighting squares the entity can trench" do 
        end
    end

    context "calling move_unit" do
        it "should work" do
            location = { 'x' => 3, 'y' => 5 }
            result = Game.move_unit(1, manager, @pieces[19], location)
            expect(result).to_not be nil
        end

        it "should move the entity" do 
        end

        it "should return an RPC for moving the unit" do 
        end
    end

    context "calling attack" do
        it "should work" do
            location = { 'x' => 5, 'y' => 5 }
            result = Game.attack(1, manager, @pieces[23], location, 'melee')
            expect(result).to_not be nil
            result = Game.attack(1, manager, @pieces[23], location, 'ranged')
            expect(result).to_not be nil
        end

        it "should perform a melee attack" do
        end

        it "should perform a ranged attack" do
        end

        it "should return an RPC for the melee attack" do 
        end
    end

    context "calling melee_attack" do
        it "should work" do
            result = Game.melee_attack(1, manager, @pieces[23], 5,5)
            expect(result).to_not be nil
        end

        it "should perform the melee attack" do
        end

        it "should return an RPC for the melee attack" do 
        end
    end

   context "calling make_trench" do
        it "should work" do
            location = { 'x' => 5, 'y' => 5 }
            result = Game.make_trench(1, manager, @pieces[23], location)
            expect(result).to_not be nil
        end

        it "should make the trench" do
        end

        it "should return an RPC for the make trench" do 
        end
    end


    context "calling ranged_attack" do
        it "should work" do
            result = Game.ranged_attack(1, manager, @pieces[23], 5,5)
            expect(result).to_not be nil
        end

        it "should perform the ranged attack" do
        end

        it "should return an RPC for the melee attack" do 
        end
    end

    context "calling end_turn" do
        it "should work" do
            result = Game.end_turn(1, manager)
            expect(result).to_not be nil
        end

        it "should end the current player's turn" do
        end

        it "should return an RPC for ending the turn" do 
        end
    end

    context "calling leave_game" do    
        it "should work" do
            result = Game.leave_game(1, manager)
            expect(result).to_not be nil
        end
        
        it "should eliminate the leaving player" do
        end

        it "should return an RPC for eliminating the leaving player" do 
        end
    end

    context "calling store" do
        it "should save the manager to a game model in database" do
        end
    end

    context "calling save" do
        it "should save the manager to a game model in redis" do
        end
    end

    context "calling get" do
        it "should return a game model from redis if available" do
        end

        it "should return a game model from database if redis not available" do
        end

        it "should return nil if game model doesn't exist" do
        end
    end
end
