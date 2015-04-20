#require "enumerable/standard_deviation"
#require "rubystats"

require_relative "./entity.rb"
require_relative "./entity_manager.rb"
Dir[File.dirname(__FILE__) + '/../component/*.rb'].each {|file| require_relative file }

=begin
	The EntityFactory is a heavy-lifter along with the EntityManager. It
	is responsible for creating standard entities. Certain entities such
	as squares on the board are rather forumlaic in how they are made.
	Rather than having to add the appropriate components manually each time,
	the EntityFactory handles this logic. The factory also provides methods
	to determine whether an entity is of a given type (like a Square or
	Player).
=end
class EntityFactory

private
	# The default creator of new entities. It creates a new entity adding
	# the desired components to it.
	#
	# Arguments
	#   entity_manager = the entity manager to add the new entity to
	#   components     = the list of components to add
	#
	# Returns
	#   the newly created Entity 
	def self.create_entity(entity_manager, components)
		# The first uses production entities, the second debugging ones.
		#entity = Entity.new
		entity = Entity.debug_entity
		components.each do |component|
			entity_manager.add_component(entity, component)
		end
		return entity
	end

public

	# This function creates a new flatland square for boards. Flatlands are
	# the standard squares that can both be traversed by troops and
	# occupied by them.
	#
	# Arguments
	#   entity_manager = the entity manager to add the new entity to
	#
	# Returns
	#   the newly created Square Entity 
	def self.flatland_square(entity_manager)
		return self.create_entity(entity_manager,
					  [TerrainComponent.flatland,
					   OccupiableComponent.new])
	end

	# This function creates a new mountain square for boards. Mountains are
	# rugged squares that are unoccupiable and impassable. They primarly
	# serve as protective boarders.
	#
	# Arguments
	#   entity_manager = the entity manager to add the new entity to
	#
	# Returns
	#   the newly created Square Entity	
	def self.mountain_square(entity_manager)
		return self.create_entity(entity_manager,
					  [TerrainComponent.mountain,
					   ImpassableComponent.new])
	end

	# This function creates a new hill square for boards. Hills are the
	# passable and occupiable version of mountians.
	#
	# TODO In future versions of the game, hills will provide some defense
	#      boosts.
	#
	# Arguments
	#   entity_manager = the entity manager to add the new entity to
	#
	# Returns
	#   the newly created Square Entity	
	def self.hill_square(entity_manager)
		return self.create_entity(entity_manager,
					  [TerrainComponent.hill,
					   OccupiableComponent.new])
	end

	# This function creates a new trench square for boards. Trenches are
	# dug from the terrain by units and are both passable and occupiable.
	#
	# TODO In future versions of the game, hills will provide some defense
	#      boosts.
	# TODO Consider adding an immalleable component to determine if a square
	#      can be turned into a trench
	#
	# Arguments
	#   entity_manager = the entity manager to add the new entity to
	#
	# Returns
	#   the newly created Square Entity
	def self.trench_square(entity_manager)
		return self.create_entity(entity_manager,
					  [TerrainComponent.trench,
					   OccupiableComponent.new])
	end

	# This function creates a new river square for boards. Rivers are
	# protective barriers similar to mountains. Like mountains they can not
	# be occupied by troops. Unlike mountains, they can be traversed.
	#
	# Arguments
	#   entity_manager = the entity manager to add the new entity to
	#
	# Returns
	#   the newly created Square Entity
	def self.river_square(entity_manager)
		return self.create_entity(entity_manager,
					  [TerrainComponent.river])
	end

	# This function populates the board in the most basic way possible. It
	# fills each row and column with a flatland square.
	#
	# Arguments
	#   entity_manager = the entity manager to add the new entity to
	#
	# Postcondition
	#   the board is properly created
	#
	# Note
	#   Each 
	def self.create_board_basic(entity_manager)
		(0...entity_manager.row).each { |row|
			(0...entity_manager.col).each { |col|
				square = self.flatland_square(entity_manager)
				entity_manager.add_component(square,
					PositionComponent.new(row, col))
				entity_manager.board[row][col] = [square, []]
			}
		}
	end

	# This function creates a new human player entity. These entities
	# represent the human players of the game.
	#
	# Arguments
	#   entity_manager = the entity manager to add the new entity to
	#   name           = the in game name of the player
	#
	# Returns
	#   the newly created Human Player Entity
	def self.human_player(entity_manager, name, id=-1, faction="blue")
		return self.create_entity(entity_manager,
					  [UserIdComponent.new(id, faction),
					   NameComponent.new(name),
					   HumanComponent.new])
	end

	# This function creates a new AI player entity. These entities
	# represent the players that are controlled by artifical intelligence
	#
	# Arguments
	#   entity_manager = the entity manager to add the new entity to
	#   name           = the name of the computer entity
	#
	# Returns
	#   the newly created AI Player Entity
	def self.ai_player(entity_manager, name, id=-1, faction="blue")
		return self.create_entity(entity_manager,
					  [UserIdComponent.new(id, faction),
					   NameComponent.new(name),
					   AIComponent.new])
	end

	# This function creates a new turn entity. These entities are responsible
	# for managing information about the current turn of the game such as
	# which player's turn it currently is and what entities of the player
	# have done actions thus far.
	#
	# Arguments
	#   entity_manager = the entity manager to add the new entity to
	#   players        = a list of the game's player entities
	#
	# Returns
	#   the newly created Turn Entity
	def self.turn_entity(entity_manager, players)
		return self.create_entity(entity_manager,
					  [TurnComponent.new(players)])
	end

	# ;)
	def self.goliath(entity_manager, owner)
		return self.create_entity(entity_manager,
					  [PieceComponent.infantry,
					   HealthComponent.new(36),
					   MotionComponent.new(-1, 1),
					   MeleeAttackComponent.new(9),
					   EnergyComponent.new(1),
					   OwnedComponent.new(owner)])
	end

	# This function creates a new AI player etity. These entities
	# represent the players that are controlled by artifical intelligence
	#
	# Arguments
	#   entity_manager = the entity manager to add the new entity to
	#   owner          = the player entity this piece belongs to
	#
	# Returns
	#   the newly created AI Player Entity
	def self.infantry(entity_manager, owner)
		return self.create_entity(entity_manager,
					  [PieceComponent.infantry,
					   HealthComponent.new(12),
					   EnergyComponent.new(18),
					   MotionComponent.new(-1, 2),
					   MeleeAttackComponent.new(6, 4),
					   RangeAttackComponent.new(6, 1, 2, [1.0], 4),
					   OwnedComponent.new(owner)])
	end

	# This function creates a new AI player etity. These entities
	# represent the players that are controlled by artifical intelligence
	#
	# Arguments
	#   entity_manager = the entity manager to add the new entity to
	#   owner          = the player entity this piece belongs to
	#
	# Returns
	#   the newly created AI Player Entity
	def self.machine_gun(entity_manager, owner)
		return self.create_entity(entity_manager,
					  [PieceComponent.machine_gun,
					   HealthComponent.new(12),
					   EnergyComponent.new(6),
					   MotionComponent.new(-1, 3),
					   MeleeAttackComponent.new(6, 6),
					   RangeAttackComponent.new(4, 1, 3, [1.0], 2),
					   OwnedComponent.new(owner)])
	end

	# This function creates a new AI player etity. These entities
	# represent the players that are controlled by artifical intelligence
	#
	# Arguments
	#   entity_manager = the entity manager to add the new entity to
	#   owner          = the player entity this piece belongs to
	#
	# Returns
	#   the newly created AI Player Entity
	def self.artillery(entity_manager, owner)
		return self.create_entity(entity_manager,
					  [PieceComponent.artillery,
					   HealthComponent.new(12),
					   EnergyComponent.new(6),
					   MotionComponent.new(-1, 6),
					   RangeAttackComponent.new(12, 3, 10, [1.0, 0.5, 0.25], 6),
					   OwnedComponent.new(owner)])
	end

	# This function creates a new command bunker entity. These entities
	# represent the command base of a player. A player will lose if the
	# opposing army is able to capture the command bunker.
	#
	# Arguments
	#   entity_manager = the entity manager to add the new entity to
	#   owner          = the player entity this piece belongs to
	#
	# Returns
	#   the newly created Command Bunker Entity
	def self.command_bunker(entity_manager, owner)
		return self.create_entity(entity_manager,
					  [PieceComponent.command_bunker,
					   HealthComponent.new(30),
					   EnergyComponent.new(10),
					   RangeAttackImmunityComponent.new,
					   OwnedComponent.new(owner)])
	end

	# This function creates a new army for a player.
	#
	# Arguments
	#   entity_manager = the entity manager to add the new entity to
	#   owner          = the player entity that owns the army
	#
	# Returns
	#   an array of the army pieces
	def self.create_army(entity_manager, owner)
		army_array = []
		army_array.push self.command_bunker(entity_manager, owner)
		3.times  {army_array.push self.artillery(entity_manager, owner)}
		7.times  {army_array.push self.machine_gun(entity_manager, owner)}
		14.times {army_array.push self.infantry(entity_manager, owner)}
		return army_array
	end

	# This function places a piece on the board
	#
	# Arguments
	#   entity_manager = the entity manager to add the new entity to
	#   piece          = the entity to place on the board
	#   row            = the row of the board
	#   col            = the col of the board
	#
	# Postcondition
	#   the piece has been placed on the board
	def self.place_piece(entity_manager, piece, row, col)
		entity_manager.add_component(piece,
			PositionComponent.new(row, col))
		entity_manager.board[row][col][1].push piece
	end

	# This function places an army in the 5x5 top left corner
	#
	# Arguments
	#   entity_manager = the entity manager to add the new entity to
	#   army_array     = the army to place on the board
	#
	# Postcondition
	#   the army has been placed on the board
	def self.place_army_top_left(entity_manager, army_array)
		army = army_array.dup
		(0...5).each {|row|
			(0...5).each { |col|
				self.place_piece(entity_manager, army.shift, row, col)
			}
		}
	end

	# This function places an army in the 5x5 bottom left corner
	#
	# Arguments
	#   entity_manager = the entity manager to add the new entity to
	#   army_array     = the army to place on the board
	#
	# Postcondition
	#   the army has been placed on the board
	def self.place_army_bottom_left(entity_manager, army_array)
		army = army_array.dup
		max_row  = entity_manager.row - 1
		max_row.step(max_row-4, -1).each {|row|
			(0...5).each { |col|
				self.place_piece(entity_manager, army.shift, row, col)
			}
		}
	end

	# This function places an army in the 5x5 top right corner
	#
	# Arguments
	#   entity_manager = the entity manager to add the new entity to
	#   army_array     = the army to place on the board
	#
	# Postcondition
	#   the army has been placed on the board
	def self.place_army_top_right(entity_manager, army_array)
		army    = army_array.dup
		max_col = entity_manager.col - 1
		(0...5).each {|row|
			max_col.step(max_col-4, -1).each { |col|
				self.place_piece(entity_manager, army.shift, row, col)
			}
		}
	end

	# This function places an army in the 5x5 bottom right corner
	#
	# Arguments
	#   entity_manager = the entity manager to add the new entity to
	#   army_array     = the army to place on the board
	#
	# Postcondition
	#   the army has been placed on the board
	def self.place_army_bottom_right(entity_manager, army_array)
		army    = army_array.dup
		max_row  = entity_manager.row - 1
		max_col = entity_manager.col - 1
		max_row.step(max_row-4, -1).each {|row|
			max_col.step(max_col-4, -1).each { |col|
				self.place_piece(entity_manager, army.shift, row, col)
			}
		}
	end

	# This function creates all the entities needed for a new basic game
	#
	# Arguments
	#   entity_manager = the entity manager to add the new entities to
	#   player_names   = the names of the players to have (max 4)
	#
	# Returns
	#   an array of the following entities:
	#
	#   [turn_entity, 
	#    [player_entity1, player_entity2, ...],
	#    [piece_entity1, piece_entity2, piece_entity3, ....]
	#   ]
	#
	# Note
	#   it is the responsiblity of the caller to make sure
	#   number_of_players <= 4
	#
	#   The basic game uses a plain board only with flatlands  
	#
	#   When initializing a new game, this is the only method that needs
	#   to be called.     
	def self.create_game_basic(entity_manager, player_names)

		self.create_board_basic(entity_manager)
		
		place_methods = [EntityFactory.method(:place_army_top_left),
				 EntityFactory.method(:place_army_bottom_right),
				 EntityFactory.method(:place_army_top_right),
				 EntityFactory.method(:place_army_bottom_left)]
		
		players = []
		pieces = []
		factions = ["red", "blue", "green", "yellow"]
		player_names.each_with_index { |name, index|
			player = self.human_player(entity_manager, name, -1, factions[index])
			army   = self.create_army(entity_manager, player)
			players.push player
			pieces.concat army
			place_methods[index].call(entity_manager, army)
		}
		
		turn = self.turn_entity(entity_manager, players)
		return [players, turn, pieces]
	end

=begin
	// TODO Talk with Vance and David about code so we can write tests for it
	
	def self.board1(entity_manager, clutter=0.25)	
		0.upto(n-1).each {|i|
			0.upto(n-1).each {|j|
				entity_manager.board[i][j] = self.tile_flatland(entity_manager)
			}
		}

		r = Random.new
		# We define probability 0 to be "no clutter", vs. n to be
		# "completely cluttered"
		n = max(entity_manager.rows, entity_manager.columns)
		gen = Rubystats::BinomialDistribution.new(n, clutter)
		gen.times {
			# Now we populate the board with random numbers
			randomi = r.rand(entity_manager.rows)
			randomj = r.rand(entity_manager.columns)

			random_Component = get_random()

			entity_manager.board[randomi][randomj].type = random_Component
		}

	end

	def get_random()
		case rand(100) + 1
		    when  1..50   then TerrainComponent.mountain
			when 50..100   then TerrainComponent.river
		end
	end
=end

end

