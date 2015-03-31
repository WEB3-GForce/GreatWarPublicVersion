require_relative "./entity/entity_factory.rb"

class Game
    attr_reader :entity_manager

    def initialize(rows=30, cols=30, player_names=["Player 1", "Player 2"])
        @entity_manager = EntityManager.new(rows, cols)
        @start_info = EntityFactory.create_game_basic(@entity_manager, player_names)
    end

    def get_start_info
        players, turn, pieces = @start_info
        return JsonFactory.game_start(@entity_manager, players, turn, pieces)
    end

    def get_full_info(requester, row=nil, col=nil)
        # return combination of get_tile_info, get_unit_info, get_player_info
    end

    def get_tile_info(requester, row=nil, col=nil)        
        # return @entity_manager.board[row][col][0]
    end

    def get_unit_info(requester, row=nil, col=nil)
        unit = @entity_manager.board[row][col][1].first
        return nil
    end

    def get_player_info(requester, name=nil)
        @entity_manager.each_entity(NameComponent) { |entity| 
            nameComp = @entity_manager[entity][NameComponent].first
            return self.player(@entity_manager, entity) if name == nameComp.name
        }
        return []
    end

    def get_all_full_info(requester)
    end

    def get_all_tile_info(requester)
    end

    def get_all_unit_info(requester)
    end

    def get_all_player_info(requester)
    end


    def get_unit_moves(requester, row=nil, col=nil)
    end

    def get_unit_melee_attacks(requester, row=nil, col=nil)
    end

    def get_unit_range_attacks(requester, row=nil, col=nil)
    end

    def get_all_unit_moves(requester, row=nil, col=nil)
    end

    def get_all_unit_melee_attacks(requester, row=nil, col=nil)
    end

    def get_all_unit_range_attacks(requester, row=nil, col=nil)
    end


    def do_move(requester, entity, row=nil, col=nil)
    end

    def do_melee_attack(requester, attacker_entity, target_entity)
    end

    def do_ranged_attack(requester, attacker_entity, target_entity)
    end

end

g = Game.new

#puts g.entity_manager
