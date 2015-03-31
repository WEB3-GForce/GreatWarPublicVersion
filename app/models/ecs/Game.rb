require_relative "./entity/entity_factory.rb"

class Game

    def init_game(rows=30, cols=30, player_names=["Player 1", "Player 2"])
        manager = EntityManager.new(rows, cols)
        players, turn, pieces = EntityFactory.create_game_basic(manager, player_names)
        start_json = JsonFactory.game_start(manager, players, turn, pieces)
        return manager, start_json
    end

    def get_full_info(requester, em, row, col)
    	return { "tile" => self.get_tile_info(requester, em, row, col),
    		 "unit" => self.get_unit_info(requester, em, row, col) }
    end

    def get_tile_info(requester, em, row, col)        
        return JsonFactory.square(em, em.board[row][col][0])
    end

    def get_unit_info(requester, em, row, col)
        entity = em.board[row][col][1].first
        return JsonFactory.piece(em, entity)
    end

    def get_player_info(requester, em, name=nil)
        em.each_entity(NameComponent) { |entity| 
            nameComp = em[entity][NameComponent].first
            return JsonFactory.player(em, entity) if name == nameComp.name
        }
        return []
    end

    def get_all_full_info(em, requester)
    	#(0..em.row).each 
    end

    def get_all_tile_info(em, requester)
    end

    def get_all_unit_info(em, requester)
    end

    def get_all_player_info(em, requester)
    end


    def get_unit_moves(requester, em, row, col)
    	entity = em.board[row][col][1].first
    	return self.get_unit_moves_entity(requester, em, entity)
    end
    
    def get_unit_entity_moves(requester, em, entity)
    	locations = MotionSystem.moveable_locations(em, entity)
    	return EntityFactory.moveable_locations(em, entity, locations)
    end

    def do_unit_move(requester, em, unit_row, unit_col, row, col)
    	entity = em.board[unit_row][unit_col][1].first
    	return self.do_move_entity(requester, em, entity, row, col)
    end

    def do_entity_unit_move(requester, em, entity, row, col)
        entity_location = em.board[row][col][0]
        return self.do_move_entity2(requester, em, entity, entity_location)
    end
    
    def do_entity_unit_move_entity(requester, em, entity, entity_location)
    	path = MotionSystem.make_move(em, entity, entity_location)
    	return JsonFactory.move(em, entity, path)
    end


    def get_unit_melee_attacks(requester, em, row, col)
    	entity = em.board[row][col][1].first
    end
    
    def get_unit_entity_melee_attacks(requester, em, row, col)
    	entity = em.board[row][col][1].first
    end
    

    def get_unit_range_attacks(requester, em, row, col)
    end
    

    def get_all_unit_moves(requester, em, row, col)
    end
    

    def get_all_unit_melee_attacks(requester, em, row, col)
    end
    

    def get_all_unit_range_attacks(requester, em, row, col)
    end


    def do_melee_attack(requester, em, attacker_entity, target_entity)
    end

    def do_ranged_attack(requester, em, attacker_entity, target_entity)
    end

end

g = Game.new

#puts g.entity_manager
