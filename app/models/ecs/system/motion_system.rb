require_relative "../component/impassable_component.rb"
require_relative "../component/motion_component.rb"
require_relative "../component/occupiable_component.rb"
require_relative "../component/owned_component.rb"
require_relative "../component/position_component.rb"
require_relative "../entity/entity_type.rb"

=begin
	The MotionSystem defines several useful methods for handling the
	movement of entities upon a board. In particular, it is capable of:
	
		- Determining which tiles an entity can move to
		- Determining a path from one tile to another
		- Moving an entity from one tile to another
	
	Any JSON movement-related requests from the frontend should be directed
	to this system
=end
class MotionSystem < System

private
	# Used within methods that determine whether an entity can move to
	# certain locations, this ensures that the entity has enough movement
	# to reach the square and that the row and column of the destination are
	# within the board.
	#
	# Arguments
	#   entity_manager = the entity manager with the board.
	#   movement       = how much movement the moving piece has left.
	#   row            = the row of the new location
	#   col            = the col of the new location
	#
	# Returns
	#   whether the position is valid to move to.
	def self.valid_move?(entity_manager, row, col, movement)
		return movement >= 0  &&
		   (0 <= row && row < entity_manager.row) &&
		   (0 <= col && col < entity_manager.col) 
	end

	# This function checks whether it is possible for an entity to pass over
	# a square.
	#
	# Arguments
	#   entity_manager = the manager and holder of all entities
	#   square         = the square entity to move over
	#   occupants      = the occupants of the square
	#   mover_owner    = the owner of the entity that is trying to move
	#
	# Returns
	#   true if the entity can pass over the square, false otherwise.
	def self.pass_over_square?(entity_manager, square, occupants, mover_owner)

		if entity_manager.has_components(square, [ImpassableComponent])
			return false
		end

		# If the square is occupied, make sure all occupants are owned
		# by the owner of the current piece. Pieces can not move through
		# enemy troops.
		occupants.each {|occupant|
			occ_owner = entity_manager.get_components(occupant, OwnedComponent).first
			return false if occ_owner.owner != mover_owner
		}
		
		return true
	end
	
	# Determines whether a square can be occupied
	#
	# Arguments
	#   entity_manager = the manager and holder of all entity data
	#   square         = the square that is being moved to
	#   occupants      = the occupants of the square
	#
	# Returns
	#   true if the square can be occupied, false if not
	def self.occupy_square?(entity_manager, square, occupants)
		return entity_manager.has_components(square, [OccupiableComponent]) &&
			occupants.empty?
	end

	# This private method determines the locations an entity can move to
	# taking into account the type of squares, the movement range of the
	# entity, other occupants of squares, etc.
	#
	# Arguments
	#   mover_owner = the owner of the entity to find the moveable locations of
	#   row         = the row that is currently being checked.
	#   col         = the column that is currently being checked
	#   movement    = the amount of movement points of the entity left
	#   results     = the array keeping track of the valid squares
	#   path        = the current path
	#
	# Postcondition
	#   results contains all the id's of the squares the entity can move to.
	#
	# When calling this function for the first time within other methods like
	# moveable_locations:
	#
	#    row      = the current row the entity is at
	#    col      = the current column the entity is at
	#    movement = the curr_movement of the entity
	#    results  = an empty array
	#    path     = an empty array
	#
	def self.determine_locations(entity_manager, mover_owner, row, col, movement, results, path)

		if !self.valid_move?(entity_manager, row, col, movement)
			return results
		end

		# Retreive the information about the square and occupants
		tile      = entity_manager.board[row][col]
		square    = tile[0]
		occupants = tile[1]
		
		# If this square has already been traversed in the path, continue.
		# Otherwise, augment it to the path
		if path.include? square 
			return results
		else 
			path.push square
		end

		if !self.pass_over_square?(entity_manager, square, occupants, mover_owner)
			return results
		end

		if self.occupy_square?(entity_manager, square, occupants) &&
		   !results.include?(square)
			results.push square
		end

		# Recursively check the square in the cardinal directions.
		new_movement = movement-1
		
		self.determine_locations(entity_manager, mover_owner, row-1, col,
					new_movement, results, path.dup)
		self.determine_locations(entity_manager, mover_owner, row+1, col,
					new_movement, results, path.dup)
		self.determine_locations(entity_manager, mover_owner, row, col-1,
					new_movement, results, path.dup)
		self.determine_locations(entity_manager, mover_owner, row, col+1,
					new_movement, results, path.dup)
	end

public

	# This function determines what locations are possible for an entity to
	# move to.
	#
	# Arguments
	#   entity_manager = the manager of the entities
	#   entity         = the entity
	#
	# Returns
	#   An array of square entities the entity can move to (nil if the
	#   entity can't move anywhere or isn't a moveable entity).
	def self.moveable_locations(entity_manager, entity)
		if !EntityType.moveable_entity?(entity_manager, entity)
			return []
		end
		
		motion_comp = entity_manager.get_components(entity, MotionComponent).first
		pos_comp    = entity_manager.get_components(entity, PositionComponent).first
		own_comp    = entity_manager.get_components(entity, OwnedComponent).first
		
		result = []
		self.determine_locations(entity_manager, own_comp.owner, pos_comp.row,
					 pos_comp.col, motion_comp.cur_movement,
					 result, [])
		return result
	end

end


