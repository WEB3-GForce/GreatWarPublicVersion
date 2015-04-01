require_relative "./entity/entity_factory.rb"
require_relative "./entity/json_factory.rb"

class Game

    def self.init_game(rows=30, cols=30, player_names=["Player 1", "Player 2"])
        manager = EntityManager.new(rows, cols)
        players, turn, pieces = EntityFactory.create_game_basic(manager, player_names)
        start_json = JsonFactory.game_start(manager, players, turn, pieces)
        return manager, start_json
    end

    def get_full_info(reqid, em, row, col)
    	return { "tile" => self.get_tile_info(reqid, em, row, col),
                 "unit" => self.get_unit_info(reqid, em, row, col) }
    end

    def get_tile_info(reqid, em, row, col)        
        return JsonFactory.square(em, em.board[row][col][0])
    end

    def get_unit_info(reqid, em, row, col)
        entity = em.board[row][col][1].first
        return JsonFactory.piece(em, entity)
    end

    def get_player_info(reqid, em, name=nil)
        em.each_entity(NameComponent) { |entity| 
            nameComp = em[entity][NameComponent].first
            return JsonFactory.player(em, entity) if name == nameComp.name
        }
        return []
    end

    def get_all_full_info(em, reqid)
    	#(0..em.row).each 
    end

    def get_all_tile_info(em, reqid)
    end

    def get_all_unit_info(em, reqid)
    end

    def get_all_player_info(em, reqid)
    end


    def get_unit_moves(reqid, em, row, col)
    	entity = em.board[row][col][1].first
    	return self.get_unit_moves_entity(reqid, em, entity)
    end
    
    def get_unit_entity_moves(reqid, em, entity)
    	locations = MotionSystem.moveable_locations(em, entity)
    	return EntityFactory.moveable_locations(em, entity, locations)
    end

    def do_unit_move(reqid, em, unit_row, unit_col, row, col)
    	entity = em.board[unit_row][unit_col][1].first
    	return self.do_move_entity(reqid, em, entity, row, col)
    end

    def do_unit_entity_move(reqid, em, entity, row, col)
        entity_location = em.board[row][col][0]
        return self.do_move_entity2(reqid, em, entity, entity_location)
    end
    
    def do_unit_entity_move_entity(reqid, em, entity, entity_location)
    	path = MotionSystem.make_move(em, entity, entity_location)
    	return JsonFactory.move(em, entity, path)
    end


    def get_unit_melee_attacks(reqid, em, row, col)
    	entity = em.board[row][col][1].first
        return self.get_unit_entity_melee_attacks(reqid, em, entity)
    end
    
    def get_unit_entity_melee_attacks(reqid, em, entity)
    	attacks = MeleeSystem.attackable_locations(em, entity)
        # return JsonFactory.melee_attacks(em, e, attacks)
    end
    

    def get_unit_range_attacks(reqid, em, row, col)
        entity = em.board[row][col][1].first
        # return self.get_unit_entity_range_attacks(reqid, em, entity)
    end

    def get_unit_entity_range_attacks(reqid, em, entity)
        attacks = RangeSystem.attackable_locations(em, entity)
        # return JsonFactory.range_attacks(em, e, attacks)
    end
    

    def get_all_unit_moves(reqid, em)
    end
    

    def get_all_unit_melee_attacks(reqid, em)
    end
    

    def get_all_unit_range_attacks(reqid, em)
    end


    def do_unit_melee_attack(reqid, em, entity, unit_row, unit_col, row, col)
        entity = em.board[unit_row][unit_col][1].first
        return self.do_unit_entity_melee_attack(reqid, em, entity, row, col)
    end

    def do_unit_entity_melee_attack(reqid, em, entity, row, col)
        entity2 = em.board[row][col][1].first
        return self.do_unit_entity_melee_attack_entity(reqid, em, entity, entity2)
    end

    def do_unit_entity_melee_attack_entity(reqid, em, entity1, entity2)
        result = MeleeSystem.update(em, entity1, entity2)
        # return JsonFactory.attack_result(result)
    end

    def do_unit_ranged_attack(reqid, em, entity, unit_row, unit_col, row, col)
        entity = em.board[unit_row][unit_col][1].first
        return self.do_unit_entity_ranged_attack(reqid, em, entity, row, col)
    end

    def do_unit_entity_ranged_attack(reqid, em, entity, row, col)
        entity2 = em.board[row][col][1].first
        return self.do_unit_entity_ranged_attack_entity(reqid, em, entity, entity2)
    end

    def do_unit_entity_ranged_attack_entity(reqid, em, entity1, entity2)
        result = RangeSystem.update(em, entity1, entity2)
        # return JsonFactory.attack_result(result)
    end

end

g = Game.new

#puts g.entity_manager6412322
