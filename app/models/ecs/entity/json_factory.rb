#Dir[File.dirname(__FILE__) + '/../component/*.rb'].each {|file| require_relative file }
#Dir[File.dirname(__FILE__) + '/../system/*.rb'].each {|file| require_relative file }
#Dir[File.dirname(__FILE__) + '/./*.rb'].each {|file| require_relative file }
=begin
	The JsonFactory is the one stop shop for all things json. Have some actions
	or entities to send to the frontend? JsonFactory has you covered. It will
	handle both sending newly created entities as well as update actions like
	movement and attack to the frontend.

	Note: It is the responsibility of the caller to ensure that the entities
	are well-formed.
=end
class JsonFactory

	# Converts a square entity into a hash object.
	#
	# Arguments
	#   entity_manager = the manager in which the entity is kept.
	#   entity         = the square entity to be jsoned
	#
	# Returns
	#   A hash that is ready to be jsoned
	def self.square(entity_manager, entity)
		terrain_comp = entity_manager.get_components(entity, TerrainComponent).first
		return {"id"      => entity,
		        "terrain" => terrain_comp.type.to_s}
	end


	# This converts a square entity into a json-ready hash. In particular,
	# this will be used for requests such as returning the path of a movement
	# which don't need to tell all the information about a square but
	# simply a way to identify it. Both the id and its x and y coordinates
	# are provided.
	#
	# Argumetns
	#   entity_manager = the manager in which the entity is kept.
	#   entity         = the square entity to be jsoned
	#
	# Returns
	#   A hash that is ready to be jsoned
	def self.square_path(entity_manager, entity)
		pos_comp = entity_manager.get_components(entity, PositionComponent).first
		return {"y"  => pos_comp.row,
		        "x"  => pos_comp.col}
	end

	# Converts a player entity into a hash object.
	#
	# Argumetns
	#   entity_manager = the manager in which the entity is kept.
	#   entity         = the player entity to be jsoned
	#
	# Returns
	#   A hash that is ready to be jsoned
	def self.player(entity_manager, entity)
		name_comp = entity_manager.get_components(entity, NameComponent).first
		user_id_comp = entity_manager.get_components(entity, UserIdComponent).first

		ai_comp = entity_manager.get_components(entity, AIComponent).first
		player_type = "CPU" if ai_comp

		human_comp = entity_manager.get_components(entity, HumanComponent).first
		player_type = "Human" if human_comp

		return {entity  => {"name"    => name_comp.name,
		                    "type"    => player_type,
		                    "userId"  => user_id_comp.id,
		                    "faction" => user_id_comp.faction }}
	end

	# Converts a turn entity into a hash object.
	#
	# Argumetns
	#   entity_manager = the manager in which the entity is kept.
	#   entity         = the turn entity to be jsoned
	#
	# Returns
	#   A hash that is ready to be jsoned
	def self.turn(entity_manager, entity)
		turn_comp = entity_manager.get_components(entity, TurnComponent).first
		return {"playerid" => turn_comp.current_turn,
		        "turnCount" => turn_comp.turn_count}
	end

	# This method is responsible for converting a piece entity into a json-
	# ready hash. In short, a piece is any element that a player can control
	# whether it be an artillery or command_bunker.
	#
	# This method handles all possible pieces (and hence makes it easier to
	# add and delete components from a given piece)
	#
	# Argumetns
	#   entity_manager = the manager in which the entity is kept.
	#   entity         = the piece entity to be jsoned
	#
	# Returns
	#   A hash that is ready to be jsoned
	def self.piece(entity_manager, entity)
		piece_hash          = Hash.new
		piece_hash["id"]    = entity

		piece_comp = entity_manager.get_components(entity, PieceComponent).first
		piece_hash["type"] = piece_comp.type.to_s

		owned_comp = entity_manager.get_components(entity, OwnedComponent).first
		piece_hash["player"] = owned_comp.owner

		pos_comp = entity_manager.get_components(entity, PositionComponent).first
		piece_hash["y"] = pos_comp.row
		piece_hash["x"] = pos_comp.col


		piece_hash["stats"] = Hash.new

		health_comp = entity_manager.get_components(entity, HealthComponent).first
		piece_hash["stats"]["health"] = {"current" => health_comp.cur_health,
		                                 "max"     => health_comp.max_health}

		energy_comp = entity_manager.get_components(entity, EnergyComponent).first
		if energy_comp
		   piece_hash["stats"]["energy"] = {"current" => energy_comp.cur_energy,
		                                    "max"     => energy_comp.max_energy}
		end

		motion_comp = entity_manager.get_components(entity, MotionComponent).first
		if motion_comp
		   piece_hash["stats"]["motion"] = {"cost" => motion_comp.energy_cost}
		end

		melee_comp = entity_manager.get_components(entity, MeleeAttackComponent).first
		if melee_comp
		   piece_hash["stats"]["melee"] = {"attack" => melee_comp.attack,
		                                   "cost"   => melee_comp.energy_cost}
		end

		range_comp = entity_manager.get_components(entity, RangeAttackComponent).first
		piece_hash["stats"]["range"] = Hash.new
		if range_comp
		   piece_hash["stats"]["range"] = {"attack" => range_comp.attack,
		                                   "min"    => range_comp.min_range,
		                                   "max"    => range_comp.max_range,
		                                   "splash" => range_comp.splash.size,
		                                   "cost"   => range_comp.energy_cost}
		end

		range_immune_comp = entity_manager.get_components(entity, RangeAttackImmunityComponent).first
		piece_hash["stats"]["range"]["immune"] = range_immune_comp != nil
		return piece_hash
	end

	# This method is similar to square_path but converts a unit to its x, y
	# coordinates.
	#
	# Argumetns
	#   entity_manager = the manager in which the entity is kept.
	#   entity         = the piece entity to be jsoned
	#
	# Returns
	#   A hash that is ready to be jsoned
	def self.piece_xy(entity_manager, entity)
		pos_comp = entity_manager.get_components(entity, PositionComponent).first
		return {"y"  => pos_comp.row,
		        "x"  => pos_comp.col}
	end

	# Converts the board into a json-ready hash. This method is particularly
	# useful for initialization of the frontend and sending the frontend the
	# data for the board.
	#
	# Argumetns
	#   entity_manager = the manager that contains the board
	#
	# Returns
	#   A hash that is ready to be jsoned
	def self.board(entity_manager)
		board_array = []
		(0...entity_manager.row).each { |row|
			(0...entity_manager.col).each { |col|
				board_array.push self.square(entity_manager,
					entity_manager.board[row][col][0])
			}
		}
		return {"width"    => entity_manager.row,
		        "height"   => entity_manager.col,
		        "squares"  => board_array}
	end

	# This method sends a request to the frontend to update energy.
	#
	# Arguments
	#   entity_manager = the manager of the entities
	#   entity         = the entity who lost energy
	#
	# Returns
	#   A hash that is ready to be jsoned
	def self.update_energy(entity_manager, entity)
		energy_comp = entity_manager.get_components(entity, EnergyComponent).first
		return [{"action"    => "updateUnitEnergy",
		         "arguments" => [entity, energy_comp.cur_energy]}]
	end


	# This method sends a request to the frontend to update health.
	#
	# Arguments
	#   entity_manager = the manager of the entities
	#   entity         = the entity who lost health
	#
	# Returns
	#   A hash that is ready to be jsoned
	def self.update_health(entity_manager, entity)
		cur_health = 0
		if entity_manager.has_key? (entity) and !entity_manager[entity].empty?
			cur_health = entity_manager.get_components(entity, HealthComponent).first.cur_health
        end
		return [{"action"    => "updateUnitHealth",
		         "arguments" => [entity, cur_health]}]
	end

	# This method produces a message for the frontend to kill a set of units.
	#
	# Arguments
	#   entity_manager = the manager of the entities
	#   units_array    = the entities to kill
	#
	# Returns
	#   A hash that is ready to be jsoned
	def self.kill_units(entity_manager, units_array)
		return [{"action"    => "killUnits",
		         "arguments" => [units_array]}]
	end

	# This method is responsible for sending all relevant game
	# start data to the frontend. Once the frontend receives this, it will
	# be able to completely initialize the browser for a new game.
	#
	# Arguments
	#   entity_manager = the manager of the entities
	#   players        = an array of player entities
	#   turn           = the turn entity denoting whose turn it is.
	#   pieces         = an array of all the pieces in the game
	#
	# Returns
	#   A hash that is ready to be jsoned
	def self.game_start(entity_manager, players, turn, pieces)
		player_hash = {}
		players.each { |player|
			player_hash.merge! self.player(entity_manager, player)
		}

		turn_hash = self.turn(entity_manager, turn)
		board     = self.board(entity_manager)

		piece_array = []
		pieces.each { |piece|
			piece_array.push self.piece(entity_manager, piece)
		}

          return [{
            "action" => "initGame",
            "arguments" => [board, piece_array, turn_hash, player_hash]
          }]
	end


	# This returns the results of a move command to the frontend. It specifies
	# the entity that moved along with the path it moved upon.
	#
	# Argumetns
	#   entity_manager = the manager that contains the entities
	#   moving_entity  = the entity that moved.
	#   path           = an array of square entities denoting the path of motion.
	#
	# Returns
	#   A hash that is ready to be jsoned
	def self.move(entity_manager, moving_entity, path)
		# path_array = []
		# path.each { |square|
		# 	path_array.push self.square_path(entity_manager, square)
		# }
		# return {"action" => "moveUnit",
		#         "arguments" =>[moving_entity, path_array]
		#        }

        	actions = []
        	squares_path = []
        	path[1, path.size].each { |square|
        		squares_path.push self.square_path(entity_manager, square)
        	}
        	actions.push({"action" => "moveUnit",
        		      "arguments" => [moving_entity, squares_path] })
        	actions.concat self.update_energy(entity_manager, moving_entity)
       		return actions
	end


      # This function converts an attack result information into an rpc for the front
      # end. In particular, it has all necessary information rcorded by the attack
      # systems. Once an entity dies, it is removed from the entity manager. Hence,
      # it would be futile to search for it. Hence, everything needed has to be
      # specified
      #
      # Arguments
      #   entity_manager   = manager of entities
      #   type             = the type of the attack
      #   attacking_entity = the entity launching the attack.
      #   attacker_type    = the piece type of the attackign entity.
      #   target_row       = the row of the targeted entity
      #   target_col       = the col of the targeted enitty
      #
      # Returns
      #   a hash ready to be sent to the frontend.
      def self.attack_animate(entity_manager, type, attacking_entity, attacker_type, target_row, target_col)
       		return [{"action"   => "attack",
       		         "arguments" =>
       		            [attacking_entity,
       		             {"y" => target_row,
       		              "x" => target_col
       		               },
       		             type,
       		             attacker_type]}]
	end

	# This returns the results of a move command to the frontend. It specifies
	# the entity that moved along with the path it moved upon.
	#
	# Argumetns
	#   entity_manager = the manager that contains the entities
	#   moving_entity  = the entity that moved.
	#   path           = an array of square entities denoting the path of motion.
	#
	# Returns
	#   A hash that is ready to be jsoned
	def self.attack(entity_manager, result)
        	actions = []
        	killed_units = []
        	energy_updated = []
        	result.each { |item|
        		if item[0] == "melee" || item[0] == "ranged"
        			actions.concat self.attack_animate(entity_manager,
        				item[0], item[1], item[2], item[4], item[5])
        			actions.concat self.update_health(entity_manager, item[3])
        			if entity_manager.has_key? item[1] and !entity_manager[item[1]].empty? and
        			   !energy_updated.include? item[1]
        				energy_updated.push item[1]
        				actions.concat self.update_energy(entity_manager, item[1])
        			end
        		elsif item[0] == "kill"
        			killed_units.push item[1]
        		end
        	}
        	actions.concat self.kill_units(entity_manager, killed_units) if !killed_units.empty?
       		return actions
	end


	# This is the helper function that performs the main work for requests
	# to determine where a unit can move or attack.
	#
	# Argumetns
	#   entity_manager = the manager that contains the entities
	#   entity         = the entity that wishes to move or attack.
	#   locations      = an array of square entities denoting the possible
	#                  squares that can be attacked or moved to
	#
	# Returns
	#   A hash that is ready to be jsoned
	def self.locations(entity_manager,  entity, locations, type)
		locations_array = []
		locations.each { |square|
			locations_array.push self.square_path(entity_manager, square)
		}
		return [{"action"  => "highlightSquares",
		        "arguments" => [type, locations_array]
		        }]
	end


	# This function is used to return a response to a moveable_locations
	# request. In particular, it contains the list of locations that the
	# specified entity can move to.
	#
	# Arguments
	#   entity_manager = the manager that contains the entities
	#   moving_entity  = the entity that wishes to move.
	#   locations      = an array of square entities denoting the possible
	#                  squares that can be moved to
	#
	# Returns
	#   A hash that is ready to be jsoned
	def self.moveable_locations(entity_manager,  moving_entity, locations)
		self.locations(entity_manager, moving_entity, locations, "move")
	end


	# This function is used to return a response to a melee_attackable_locations
	# request. In particular, it contains the list of locations that the
	# specified entity can melee attack.
	#
	# Arguments
	#   entity_manager = the manager that contains the entities
	#   melee_entity  = the entity that wishes to attack.
	#   locations      = an array of square entities denoting the possible
	#                  squares that the entity can melee attack
	#
	# Returns
	#   A hash that is ready to be jsoned
	def self.melee_attackable_locations(entity_manager,  melee_entity, locations)
		self.locations(entity_manager, melee_entity, locations, "attack")
	end


	# This function is used to return a response to a range_attackble_locations
	# request. In particular, it contains the list of locations that the
	# specified entity can range attack.
	#
	# Argumetns
	#   entity_manager = the manager that contains the entities
	#   range_entity  = the entity that wishes to attack.
	#   locations      = an array of square entities denoting the possible
	#                  squares that can range attack
	#
	# Returns
	#   A hash that is ready to be jsoned
	def self.range_attackable_locations(entity_manager,  range_entity, locations)
		self.locations(entity_manager, range_entity, locations, "attack")
	end


	# Converts a turn entity into a hash object.
	#
	# Argumetns
	#   entity_manager = the manager in which the entity is kept.
	#   entity         = the turn entity to be jsoned
	#
	# Returns
	#   A hash that is ready to be jsoned
	def self.end_turn(entity_manager, entity)
		return [{"action"    => "setTurn",
		        "arguments" => [self.turn(entity_manager, entity)]}]
	end


	def self.actions(entity_manager, entity, can_move, can_melee, can_range)

		actions = []

		if can_move
		 actions.push({"name" => "move",
		               "cost" => entity_manager[entity][MotionComponent].first.energy_cost})
		end

		if can_melee
		 actions.push({"name" => "melee",
		               "cost" => entity_manager[entity][MeleeAttackComponent].first.energy_cost})
		end

		if can_range
		 actions.push({"name" => "ranged",
		               "cost" => entity_manager[entity][RangeAttackComponent].first.energy_cost})
		end

		return [{"action"    => "showUnitActions",
		        "arguments" => [actions]}]
	end


	def self.remove_player(entity_manager, result)
		remove_player_result = result[0]
		turn_change_result   = result[1]
		game_over_result     = result[2]

		actions = []
		if !remove_player_result.nil?
			players_removed = remove_player_result[1]
			players_removed.each { |player| 
				actions.push({ "actions" => "eliminatePlayer",
						  	   "arguments" => [player] })
			}
		end
		if !game_over_result.nil?
			winner = game_over_result[1]
			actions.push({ "actions" => "gameOver", 
						   "arguments" => [winner] })
		end
		if !turn_change_result.nil?
		        turn = em.get_entities_with_components(TurnComponent).first
		        actions.push(self.end_turn(entity_manager, turn))
		end

		return actions
	end


	# Actions to handle:
	#   Attack
	#   Attackable locations
	#   Turn end
	#   Player finished
	#   Game over
end

#{ response: "board"
#  locations: [{"terrain": "flatland"}, {"terrain": "river"}]
#}

#{ response: "infantry"
#  locations: [{type = "infantry", x => 0, y => 1}]
#}

#{ method: "moveable_locations"
#  args: [entity_wishing_to_move]
#}
#{ response: "moveable_locations"
#  locations: [[0,1], [0,2], [0,3] ...]
#}
#{ method: "move_piece"
#  args: [entity_to_move, x, y]
#}
#{ response: "move_piece"
#  path: [[0,1], [0,2], [0,3] ...]
#}

