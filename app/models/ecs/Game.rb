require_relative "./entity/entity_factory.rb"
require_relative "./entity/entity_manager.rb"
require_relative "./entity/json_factory.rb"
require_relative "./system/motion_system.rb"
require_relative "./system/melee_system.rb"
require_relative "./system/range_system.rb"
require_relative "./system/turn_system.rb"
require_relative "./system/remove_player_system.rb"

class Game

    def self.init_game(users, path=nil)
        if path.nil?
            rows = 11
            cols = 11
            terrainIds = [-3, -3, -4, -4, -1, -1, -1, -1, -3, -3, -3, 
                          -3, -3, -4, -4, -1, -1, -1, -1, -3, -2, -3, 
                          -4, -4, -4, -4, -1, -1, -1, -1, -3, -3, -3, 
                          -4, -4, -4, -4, -1, -1, -1, -1, -1, -1, -1, 
                          -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 
                          -5, -5, -5, -5, -5, -5, -5, -5, -5, -5, -5, 
                          -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 
                          -1, -1, -1, -1, -1, -1, -1, -4, -4, -4, -4, 
                          -3, -3, -3, -1, -1, -1, -1, -4, -4, -4, -4, 
                          -3, -2, -3, -1, -1, -1, -1, -4, -4, -3, -3,
                          -3, -3, -3, -1, -1, -1, -1, -4, -4, -3, -3 ]
            pieceIds = [ -12, nil, nil, -10, -10, nil, nil, nil, nil, nil, nil, 
                         nil, -13, -11, -10, -10, nil, nil, nil, nil, nil, nil, 
                         nil, -11, -11, -10, -10, nil, nil, nil, nil, nil, nil, 
                         -10, -10, -10, -10, nil, nil, nil, nil, nil, nil, nil, 
                         -10, -10, -10, nil, nil, nil, nil, nil, nil, nil, nil, 
                         nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, 
                         nil, nil, nil, nil, nil, nil, nil, nil, -20, -20, -20,  
                         nil, nil, nil, nil, nil, nil, nil, -20, -20, -20, -20,  
                         nil, nil, nil, nil, nil, nil, -20, -20, -21, -21, nil, 
                         nil, nil, nil, nil, nil, nil, -20, -20, -21, -23, nil,
                         nil, nil, nil, nil, nil, nil, -20, -20, nil, nil, -22 ]
        else
            file = File.read(path)
            hash = JSON.parse(file)

            rows = hash['height']
            cols = hash['width']
            terrainIds = hash['layers'][0]['data']
            pieceIds = hash['layers'][1]['data']
        end

        em = EntityManager.new(rows, cols)
        em = EntityFactory.create_game(em, users, terrainIds, pieceIds)
        return em
    end

    def self.get_game_state(req_id, em)
      player_id = self.get_player_id(req_id, em)
      return JsonFactory.game_start(em, player_id)
    end

    def self.get_user_channels(em)
      channels = []
      em.each_entity(UserIdComponent) do |e|
        channels << em[e][UserIdComponent][0].channel
      end
      return channels
    end

    def self.each_coord(req_id, em)
        (0..em.row).each { |row|
            (0..em.col).each { |col|
                yield row, col
            }
        }
    end

    def self.extract_coord(location)
        return location['y'], location['x']
    end

    def self.verify_owner(req_id, em, entity)
        entity_requester = nil
        em.each_entity(UserIdComponent) { |e|
            if em[e][UserIdComponent][0].id == req_id
                entity_requester = e
                break
            end
        }
        entity_owner = em[entity][OwnedComponent][0].owner;
        return entity_requester == entity_owner
    end
    
    def self.verify_turn(req_id, em)
        return em[TurnSystem.current_turn(em)][UserIdComponent][0].id == req_id
    end

    def self.get_player_id(req_id, em)
      em.each_entity(UserIdComponent) { |e|
        if em[e][UserIdComponent][0].id == req_id
          return e
        end
      }
    end

    def self.get_full_info(req_id, em, row, col)
    	return { "tile" => self.get_tile_info(req_id, em, row, col),
                 "unit" => self.get_unit_info(req_id, em, row, col) }
    end

    def self.get_tile_info(req_id, em, row, col)
        return JsonFactory.square(em, em.board[row][col][0])
    end

    def self.get_unit_info(req_id, em, row, col)
        entity = em.board[row][col][1].first
        return JsonFactory.piece(em, entity)
    end

    def self.get_player_info(req_id, em, name=nil)
        em.each_entity(NameComponent) { |entity|
            nameComp = em[entity][NameComponent].first
            return JsonFactory.player(em, entity) if name == nameComp.name
        }
        return {}
    end


    def self.get_all_full_info(req_id, em)
        all_info = []
        self.each_coord(req_id, em).each { |row, col|
            all_info << self.get_full_info(req_id, em, row, col)
        }
        return all_info
    end

    def self.get_all_tile_info(req_id, em)
        all_info = []
        self.each_coord(req_id, em).each { |row, col|
            all_info << self.get_tile_info(req_id, em, row, col)
        }
        return all_info
    end

    def self.get_all_unit_info(req_id, em)
        all_info = []
        self.each_coord(req_id, em).each { |row, col|
            all_info << self.get_unit_info(req_id, em, row, col)
        }
        return all_info
    end

    def self.get_all_player_info(req_id, em)
        all_info = []
        em.each_entity(NameComponent) { |entity|
            nameComp = em[entity][NameComponent].first
            all_info << JsonFactory.player(em, entity)
        }
        return all_info
    end


    def self.get_unit_actions(req_id, em, entity)
        can_move = !MotionSystem.moveable_locations(em, entity).empty?
        can_melee = !MeleeSystem.attackable_locations(em, entity).empty?
        can_range = !RangeSystem.attackable_locations(em, entity).empty?

        return JsonFactory.actions(em, entity, can_move, can_melee, can_range)
    end

    def self.get_unit_moves(req_id, em, entity)
    	locations = MotionSystem.moveable_locations(em, entity)
    	return JsonFactory.moveable_locations(em, entity, locations)
    end

    def self.get_unit_melee_attacks(req_id, em, entity)
        attacks = MeleeSystem.attackable_range(em, entity)
        return JsonFactory.melee_attackable_locations(em, entity, attacks)
    end

    def self.get_unit_ranged_attacks(req_id, em, entity)
        attacks = RangeSystem.attackable_range(em, entity)
        return JsonFactory.range_attackable_locations(em, entity, attacks)
    end


    def self.move_unit(req_id, em, entity, location)
        row, col = self.extract_coord(location)
        square = em.board[row][col][0]
        path = MotionSystem.make_move(em, entity, square)
        return JsonFactory.move(em, entity, path)
    end

    def self.attack(req_id, em, entity, square, type)

    	if type == "melee"
    		return self.melee_attack(req_id, em, entity, square['y'], square['x'])
    	end
    	if type == "ranged"
    		return self.ranged_attack(req_id, em, entity, square['y'], square['x'])
    	end
    end

    def self.melee_attack(req_id, em, entity, row, col)
        target = em.board[row][col][1].first
        attack_result = MeleeSystem.update(em, entity, target)
      # player_result = RemovePlayerSystem.update(em)
        result = JsonFactory.melee_attack(em, attack_result)
        # result += JsonFactory.remove_player(em, player_result)
        return result
    end

    def self.ranged_attack(req_id, em, entity, row, col)
        target = em.board[row][col][1].first
        result = RangeSystem.update(em, entity, target)
        return JsonFactory.ranged_attack(em, result)
    end

    # End the turn for the current player.
    def self.end_turn(req_id, em)
        # if em[TurnSystem.current_turn(em)][UserIdComponent][0].id != req_id
        #    return {}
        # end

        TurnSystem.update(em)
        turn = em.get_entities_with_components(TurnComponent).first
        return JsonFactory.end_turn(em, turn)
    end

    def self.leave_game(req_id, em)
        em.each_entity(UserIdComponent) { |e|
            if em[e][UserIdComponent][0].id == req_id
                result = RemovePlayerSystem.remove_player(em, e)
                return JsonFactory.remove_player(em, result)
            end
        }
    end

    def self.store(id, manager)
      gama = Gama.find(id)
      gama.manager = Marshal::dump(manager)
      gama.save
    end

    def self.save(id, manager)
      $redis.set(id, Marshal::dump(manager))
    end
    
    def self.get(id)
      manager = $redis.get(id)
      if manager
        Marshal::load(manager)
      else
        gama = Gama.find(id)
        if gama.manager
          Marshal::load(gama.manager)
        else
          nil
        end
      end
    end
end

# users = [OpenStruct.new({name: "1", id: -1, channel: "NA"}),
#          OpenStruct.new({name: "2", id: -1, channel: "NA"}), ]
# em = Game.init_game(users)
# puts em
