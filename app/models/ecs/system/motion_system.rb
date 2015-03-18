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
			occ_owner = entity_manager.get_components(occupant,
				OwnedComponent).first
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

	# Moves an entity from its old position to its new position
	#
	# Arguments
	#   entity_manager = the manager and holder of all entity data
	#   entity         = the entity to move
	#   start_pos      = the PositionComponent of the entity
	#   end_pos        = the PositionComponent of the destination square
	#
	# Postcondition
	#   the entity has been moved
	def self.move_entity(entity_manager, entity, start_pos, end_pos)
		# Update the board so that the entity now occupies the new
		# square and no longer the old.		
		entity_manager.board[start_pos.row][start_pos.col][1].delete(entity)
		entity_manager.board[end_pos.row][end_pos.col][1].push(entity)
		
		# Update the entity's PositionComponent to be the new square
		entity_manager[entity][PositionComponent].delete(start_pos)
		entity_manager.add_component(entity,
			PositionComponent.new(end_pos.row, end_pos.col))
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
	# This also includes the square the entity is currently standing on.
	# Delete this square if it is not desired.
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
		new_pos = [[row-1, col], [row+1, col], [row, col-1],[row, col+1]]
		
		new_pos.each { |row, col|
			self.determine_locations(entity_manager, mover_owner,
						 row, col, new_movement,
						 results, path.dup)
		}
	end

	# Akin to determine_location, this function determines if there is a path
	# from one square to another.
	#
	# Arguments
	#   mover_owner = the owner of the entity that is moving
	#   row         = the row that is currently being checked.
	#   col         = the column that is currently being checked
	#   end_row     = the row of the destination
	#   end_col     = the column of the destination
	#   movement    = the amount of movement points of the entity left
	#   path        = the path from the origin square to the current square
	#
	# Returns
	#   the path from the origin to the destination or nil if there is none
	#
	# When calling this function for the first time within other methods like
	# moveable_locations:
	#
	#    path = an empty array
	#
	# Note:
	#   Although a path may exist form one point to another, this does not
	#   necessarily mean that the destination is occupiable.
	def self.determine_path(entity_manager, mover_owner, row, col, end_row, end_col, movement, path)

		if !self.valid_move?(entity_manager, row, col, movement)
			return []
		end

		# Retreive the information about the square and occupants
		tile      = entity_manager.board[row][col]
		square    = tile[0]
		occupants = tile[1]
		
		# If this square has already been traversed in the path, abort.
		# Otherwise, augment it to the path
		if path.include? square 
			return []
		else 
			path.push square
		end

		if !self.pass_over_square?(entity_manager, square, occupants, mover_owner)
			return []
		end
		
		# If the current square is the desire square, a path has been
		# found
		if row == end_row && col == end_col
			return path
		end

		# Recursively check the square in the cardinal directions.
		new_movement = movement-1
		new_pos = [[row-1, col], [row+1, col], [row, col-1],[row, col+1]]
		
		answer = []
		new_pos.each { |row, col|
		
			new_path = self.determine_path(entity_manager, mover_owner,
						       row, col, end_row, end_col,
						       new_movement, path.dup)	 

			if (answer.empty? || answer.size > new_path.size) &&
			   !new_path.empty?		     
				answer = new_path
			end
		}
		return answer
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

		# Don't include the square the entity is currently standing on.
		result.delete entity_manager.board[pos_comp.row][pos_comp.col][0]
		return result
	end
	
	# Moves an entity from its original location to a new square
	#
	# Arguments
	#   entity_manager = the manager of entities
	#   entity         = the entity to be moved
	#   new_square     = the new location for the entity to move to
	#
	# Returns
	#   the path the entity took to move to the new location or nil if
	#   the move was invalid
	#
	# Note
	#   the function does sanity checks such as making sure the entity is
	#   moveable, new_square is actually a square_entity, the entity can
	#   indeed reach the new_square, the new_square is not occupied, etc.
	def self.make_move(entity_manager, entity, new_square)
		if !EntityType.moveable_entity?(entity_manager, entity) ||
		   !EntityType.square_entity?(entity_manager, new_square)
			return nil
		end

		end_pos   = entity_manager.get_components(new_square, PositionComponent).first
		occupants = entity_manager.board[end_pos.row][end_pos.col][1]
		
		if !self.occupy_square?(entity_manager, new_square, occupants)
			return nil
		end

		motion_comp = entity_manager.get_components(entity, MotionComponent).first
		pos_comp    = entity_manager.get_components(entity, PositionComponent).first
		own_comp    = entity_manager.get_components(entity, OwnedComponent).first
		
		path = self.determine_path(entity_manager, own_comp.owner, pos_comp.row,
			pos_comp.col, end_pos.row, end_pos.col, motion_comp.cur_movement, [])
			
		if path == []
			return nil
		end

		self.move_entity(entity_manager, entity, pos_comp, end_pos)			
		return path
	end
end


