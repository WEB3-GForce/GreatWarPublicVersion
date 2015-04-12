require_relative '../../../spec_helper'

describe JsonFactory do

    let(:row)               {3}
    let(:col)               {3}
    let(:manager)           {EntityManager.new(row, col)}
    let(:human1)            {EntityFactory.human_player(manager, "David")}
    let(:ai)                {EntityFactory.ai_player(manager, "R.O.B")}
    let(:infantry)          {EntityFactory.infantry(manager, human1)}
    let(:machine_gun)       {EntityFactory.machine_gun(manager, human1)}
    let(:artillery)         {EntityFactory.artillery(manager, human1)}  
    let(:command_bunker)    {EntityFactory.command_bunker(manager, human1)}
    let(:flatland00)        {EntityFactory.flatland_square(manager)}
    let(:river01)           {EntityFactory.river_square(manager)}
    let(:mountain02)        {EntityFactory.mountain_square(manager)}
    let(:flatland10)        {EntityFactory.flatland_square(manager)}
    let(:flatland11)        {EntityFactory.flatland_square(manager)}
    let(:flatland12)        {EntityFactory.flatland_square(manager)}
    let(:flatland20)        {EntityFactory.flatland_square(manager)}
    let(:flatland21)        {EntityFactory.flatland_square(manager)}
    let(:flatland22)        {EntityFactory.flatland_square(manager)}
        let(:square_array)      {[flatland00, river01,    mountain02,
                          flatland10, flatland11, flatland12,
                          flatland20, flatland21, flatland22]}
    let(:turn)              {EntityFactory.turn_entity(manager, [human1, ai])}

    def set_simple
        array = square_array.dup   
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
        manager.board[0][0][1].push infantry
        manager.add_component(infantry, PositionComponent.new(0, 0))
        manager.board[1][1][1].push machine_gun
        manager.add_component(machine_gun, PositionComponent.new(1, 1))
        manager.board[2][2][1].push artillery
        manager.add_component(artillery, PositionComponent.new(2, 2))
        manager.board[2][0][1].push command_bunker
        manager.add_component(command_bunker, PositionComponent.new(2, 0))
    end

    context "when calling square" do
        it "should return a hash with the attributes of the square" do
            expect(JsonFactory.square(manager, flatland00)).to eq(
                {"id" => flatland00, "terrain" => "flatland"})
            expect(JsonFactory.square(manager, river01)).to eq(
                {"id" => river01, "terrain" => "river"})
            expect(JsonFactory.square(manager, mountain02)).to eq(
                {"id" => mountain02, "terrain" => "mountain"})
        end
    end

    context "when calling player" do
        it "should return a hash for a human" do
            expect(JsonFactory.player(manager, human1)).to eq(
                {"id" => human1, "name" => "David",
                 "type" => "Human", "userId" => -1})
        end

        it "should return a hash for an ai" do
            expect(JsonFactory.player(manager, ai)).to eq(
                {"id" => ai, "name" => "R.O.B",
                 "type" => "CPU", "userId" => -1})
        end
    end

    context "when calling turn" do
        it "should return a hash for a turn entity" do
            expect(JsonFactory.turn(manager, turn)).to eq(
                {"playerid" => human1})
                
            manager.get_components(turn, TurnComponent).first.next_turn
            expect(JsonFactory.turn(manager, turn)).to eq(
                {"playerid" => ai})
        end
    end


    context "when calling square_path" do
        it "should return a hash with the attributes of the square" do
            set_simple
            expect(JsonFactory.square_path(manager, flatland00)).to eq(
                {"x" => 0, "y" => 0})
            expect(JsonFactory.square_path(manager, river01)).to eq(
                {"x" => 0, "y" => 1})
            expect(JsonFactory.square_path(manager, mountain02)).to eq(
                {"x" => 0, "y" => 2})
        end
    end

    context "when calling piece" do
        it "should return a proper hash for an infantry" do
            set_intermediate
            piece_comp  = manager.get_components(infantry, PieceComponent).first
            pos_comp    = manager.get_components(infantry, PositionComponent).first
            health_comp = manager.get_components(infantry, HealthComponent).first
            energy_comp = manager.get_components(infantry, EnergyComponent).first
            motion_comp = manager.get_components(infantry, MotionComponent).first
            melee_comp  = manager.get_components(infantry, MeleeAttackComponent).first
            range_comp  = manager.get_components(infantry, RangeAttackComponent).first
            answer = {"id"     => infantry,
                      "type"   => PieceComponent.infantry.type.to_s,
                      "player" => human1,
                      "x"      => pos_comp.row,
                      "y"      => pos_comp.col,
                      "stats"  => {
                          "health" => {"current" => health_comp.cur_health,
                                       "max"     => health_comp.max_health},
                          "energy" => {"current" => energy_comp.cur_energy,
                                       "max"     => energy_comp.max_energy},
                          "motion" => {"cost"    => motion_comp.energy_cost},   
                          "melee"  => {"attack"  => melee_comp.attack,
                                       "cost"    => melee_comp.energy_cost},
                          "range"  => {"attack"  => range_comp.attack,
                                       "min"     => range_comp.min_range,
                                       "max"     => range_comp.max_range,
                                       "splash"  => range_comp.splash.size,
                                       "cost"    => range_comp.energy_cost,
                                       "immune"  => false}}
                        }
        
            expect(JsonFactory.piece(manager, infantry)).to eq(answer)
        end

        it "should return a proper hash for a machine_gun" do
            set_intermediate
            piece_comp  = manager.get_components(machine_gun, PieceComponent).first
            pos_comp    = manager.get_components(machine_gun, PositionComponent).first
            health_comp = manager.get_components(machine_gun, HealthComponent).first
            energy_comp = manager.get_components(machine_gun, EnergyComponent).first
            motion_comp = manager.get_components(machine_gun, MotionComponent).first
            melee_comp  = manager.get_components(machine_gun, MeleeAttackComponent).first
            range_comp  = manager.get_components(machine_gun, RangeAttackComponent).first
            answer = {"id"     => machine_gun,
                      "type"   => PieceComponent.machine_gun.type.to_s,
                      "player" => human1,
                      "x"      => pos_comp.row,
                      "y"      => pos_comp.col,
                      "stats"  => {
                          "health" => {"current" => health_comp.cur_health,
                                       "max"     => health_comp.max_health},
                          "energy" => {"current" => energy_comp.cur_energy,
                                       "max"     => energy_comp.max_energy},
                          "motion" => {"cost"    => motion_comp.energy_cost},   
                          "melee"  => {"attack"  => melee_comp.attack,
                                       "cost"    => melee_comp.energy_cost},
                          "range"  => {"attack"  => range_comp.attack,
                                       "min"     => range_comp.min_range,
                                       "max"     => range_comp.max_range,
                                       "splash"  => range_comp.splash.size,
                                       "cost"    => range_comp.energy_cost,
                                       "immune"  => false}}
                    }
        
            expect(JsonFactory.piece(manager, machine_gun)).to eq(answer)
        end

        it "should return a proper hash for an artillery" do
            set_intermediate
            piece_comp  = manager.get_components(artillery, PieceComponent).first
            pos_comp    = manager.get_components(artillery, PositionComponent).first
            health_comp = manager.get_components(artillery, HealthComponent).first
            energy_comp = manager.get_components(artillery, EnergyComponent).first
            motion_comp = manager.get_components(artillery, MotionComponent).first
            melee_comp  = manager.get_components(artillery, MeleeAttackComponent).first
            range_comp  = manager.get_components(artillery, RangeAttackComponent).first
            answer = {"id"     => artillery,
                      "type"   => PieceComponent.artillery.type.to_s,
                      "player" => human1,
                      "x"      => pos_comp.row,
                      "y"      => pos_comp.col,
                      "stats"  => {
                          "health" => {"current" => health_comp.cur_health,
                                       "max"     => health_comp.max_health},
                          "energy" => {"current" => energy_comp.cur_energy,
                                       "max"     => energy_comp.max_energy},
                          "motion" => {"cost"    => motion_comp.energy_cost},
                          "range"  => {"attack"  => range_comp.attack,
                                       "min"     => range_comp.min_range,
                                       "max"     => range_comp.max_range,
                                       "splash"  => range_comp.splash.size,
                                       "cost"    => range_comp.energy_cost,
                                       "immune"  => false}}
                    }                         
        
            expect(JsonFactory.piece(manager, artillery)).to eq(answer)
        end

        it "should return a proper hash for an command_bunker" do
            set_intermediate
            piece_comp  = manager.get_components(command_bunker, PieceComponent).first
            pos_comp    = manager.get_components(command_bunker, PositionComponent).first
            health_comp = manager.get_components(command_bunker, HealthComponent).first
            energy_comp = manager.get_components(command_bunker, EnergyComponent).first
            melee_comp  = manager.get_components(command_bunker, MeleeAttackComponent).first
            range_comp  = manager.get_components(command_bunker, RangeAttackComponent).first
            answer = {"id"     => command_bunker,
                      "type"   => PieceComponent.command_bunker.type.to_s,
                      "player"  => human1,
                      "x"      => pos_comp.row,
                      "y"      => pos_comp.col,
                      "stats"  => {
                          "health" => {"current" => health_comp.cur_health,
                                       "max"     => health_comp.max_health},
                          "energy" => {"current" => energy_comp.cur_energy,
                                       "max"     => energy_comp.max_energy},
                          "range"  => {"immune"  => true}}
                    }                         
        
            expect(JsonFactory.piece(manager, command_bunker)).to eq(answer)
        end
    end


    context "when calling board" do
        it "should return a hash of the board" do
            set_simple
            board_array = []
            square_array.each { |square|
                board_array.push JsonFactory.square(manager, square)
            }
            expect(JsonFactory.board(manager)).to eq(
                {"width" => row, "height" => col, "squares" => board_array})
        end
    end


    context "when calling game_start" do
        it "should return a hash of the game_start" do
            set_intermediate
            players = [human1, ai]
            player_array = []
            players.each { |player|
                player_array.push JsonFactory.player(manager, player)
            }
            pieces = [infantry, machine_gun, artillery, command_bunker]
            pieces_array = []
            pieces.each { |piece|
                pieces_array.push JsonFactory.piece(manager, piece)
            }

            expect(JsonFactory.game_start(manager, players, turn, pieces)).to eq(
                {"action" => "initGame", 
                 "arguments" => [JsonFactory.board(manager),
                                 pieces_array,
                                 JsonFactory.turn(manager, turn),
                                 player_array]})
        end
    end

    context "when calling move" do
        it "should return a hash of a move action" do
            set_simple
            path = [flatland20, flatland10, flatland00]
            path_array = []
            path.each { |square|
                path_array.push JsonFactory.square_path(manager, square)
            }
            expect(JsonFactory.move(manager, infantry, path)).to eq(
                {"action" => "move", "arguments" => [infantry, path_array]})
        end
    end


    context "when calling moveable locations" do
        it "should return a hash of a json for a moveable locations request" do
            set_simple
            locations = []
            square_array.each { |square|
                locations.push JsonFactory.square_path(manager, square)
            }
            expect(JsonFactory.moveable_locations(manager, machine_gun, square_array)).to eq(
                {"action" => "highlightSquares", "arguments" => ["move", locations]})
        end
    end

end