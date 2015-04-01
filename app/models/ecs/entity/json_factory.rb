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
		return {"id" => entity,
		        "row"  => pos_comp.row,
		        "col"  => pos_comp.col}
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

		ai_comp = entity_manager.get_components(entity, AIComponent).first
		player_type = "CPU" if ai_comp	

		human_comp = entity_manager.get_components(entity, HumanComponent).first
		player_type = "Human" if human_comp

		return {"id"      => entity,
		        "name"    => name_comp.name,
		        "type"    => player_type}
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
		return {"id"      => entity,
		        "current" => turn_comp.current_turn}
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
		piece_hash       = Hash.new
		piece_hash["id"] = entity
		
		piece_comp = entity_manager.get_components(entity, PieceComponent).first
		piece_hash["type"] = piece_comp.type.to_s

		owned_comp = entity_manager.get_components(entity, OwnedComponent).first
		piece_hash["owner"] = owned_comp.owner

		pos_comp = entity_manager.get_components(entity, PositionComponent).first
		piece_hash["position"] = {"row" => pos_comp.row,
		                          "col" => pos_comp.col}

		health_comp = entity_manager.get_components(entity, HealthComponent).first
		piece_hash["health"] = {"current" => health_comp.cur_health,
		                        "max"     => health_comp.max_health}

		energy_comp = entity_manager.get_components(entity, EnergyComponent).first
		if energy_comp
		   piece_hash["energy"] = {"current" => energy_comp.cur_energy,
		                           "max"     => energy_comp.max_energy}
		end

		motion_comp = entity_manager.get_components(entity, MotionComponent).first
		if motion_comp
		   piece_hash["motion"] = {"cost" => motion_comp.energy_cost}
		end

		melee_comp = entity_manager.get_components(entity, MeleeAttackComponent).first
		if melee_comp
		   piece_hash["melee"] = {"attack" => melee_comp.attack,
		                          "cost"   => melee_comp.energy_cost}
		end

		range_comp = entity_manager.get_components(entity, RangeAttackComponent).first
		piece_hash["range"] = Hash.new
		if range_comp
		   piece_hash["range"] = {"attack" => range_comp.attack,
		                          "range"  => {"min" => range_comp.min_range,
		                                       "max" => range_comp.max_range},
		                          "splash" => range_comp.splash.size,
		                          "cost"   => range_comp.energy_cost}
		end

		range_immune_comp = entity_manager.get_components(entity, RangeAttackImmunityComponent).first
		piece_hash["range"]["immune"] = range_immune_comp != nil
		return piece_hash
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
		return {"row"      => entity_manager.row,
		        "col"      => entity_manager.col,
		        "squares"  => board_array}
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
		player_array = []
		players.each { |player|
			player_array.push self.player(entity_manager, player)
		}
	
		turn_hash = self.turn(entity_manager, turn)
		board     = self.board(entity_manager)
		
		piece_array = []
		pieces.each { |piece|
			piece_array.push self.piece(entity_manager, piece)
		}

          return {
            "action" => "init_game",
            "arguments" => [board, player_array, turn_hash, piece_array]
          }
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
		path_array = []
		path.each { |square|
			path_array.push self.square_path(entity_manager, square)
		}
		return {"response" => "move",
		        "mover"    => moving_entity,
		        "path"     => path_array}
	end

	# This function is used to return a response to a moveable_locations
	# request. In particular, it contains the list of locations that the
	# specified entity can move to.
	#
	# Argumetns
	#   entity_manager = the manager that contains the entities
	#   moving_entity  = the entity that wishes to move.
	#   locations      = an array of square entities denoting the possible
	#                  squares that can be moved to
	#
	# Returns
	#   A hash that is ready to be jsoned	
	def self.moveable_locations(entity_manager,  moving_entity, locations)
		locations_array = []
		locations.each { |square|
			locations_array.push self.square_path(entity_manager, square)
		}
		return {"response"  => "moveable locations",
		        "mover"     => moving_entity,
		        "locations" => locations_array}
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

