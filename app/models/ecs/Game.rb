require_relative "./entity/entity_factory.rb"

class Game
    attr_reader :entity_manager

    def initialize(rows=30, cols=30, player_names=["Player 1", "Player 2"])
        @entity_manager = EntityManager.new(rows, cols)
        EntityFactory.create_game_basic(@entity_manager, player_names)
    end


    def get_full_info(requester, row=nil, col=nil)
    end

    def get_tile_info(requester, row=nil, col=nil)
    end

    def get_unit_info(requester, row=nil, col=nil)
    end

    def get_player_info(requester, name=nil)
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

puts g.entity_manager