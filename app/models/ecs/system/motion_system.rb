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

	# This private method determines the locations an entity can move to
	# taking into account the type of squares, the movement range of the
	# entity, other occupants of squares, etc.
	#
	# Arguments
	#   owner    = the owner of the entity to find the moveable locations of
	#   row      = the row that is currently being checked.
	#   col      = the column that is currently being checked
	#   movement = the amount of movement points of the entity left
	#   results  = the array keeping track of the valid squares
	#   path     = the current path
	#
	# Postcondition
	#   results contains all the entity id's that the entity can move to.
	def self.determine_locations(entity_manager, owner, row, col, movement, results, path)

		# Return immediately if the entity can't move any further,
		# or the rows and columns are out of bounds.
		if movement < 0                           ||
		   (0 > row || row >= entity_manager.row) ||
		   (0 > col || col >= entity_manager.col) 
			return results
		end

		tile      = entity_manager.board[row][col]
		square    = tile[0]
		occupants = tile[1]
		
		# If this square has already been traversed in the path, continue.
		if path.include? square 
			return results
		end
		
		# Otherwise, include it in the path.
		path.push square

		# If the square is impassable, the entity can not pass
		# through it
		if entity_manager.has_components(square, [ImpassableComponent])
			return results
		end

		# If the square is occupiable and currently unoccupied, add it
		# to the results if it has not been added already
		if entity_manager.has_components(square, [OccupiableComponent]) &&
		   occupants.empty? && !results.include?(square)
			results.push square
		end
		
		# If the square is occupied, make sure all occupants are owned
		# by the owner of the current piece. Pieces can not move through
		# enemy troops.
		if !occupants.empty?
			occupants.each {|occupant|
				occ_owner = entity_manager.get_components(occupant, OwnedComponent).first
				return results if occ_owner.owner != owner
			}
		end

		# Recursively check the square in the cardinal directions.
		self.determine_locations(entity_manager, owner, row-1, col,
					movement-1, results, path.dup)
		self.determine_locations(entity_manager, owner, row+1, col,
					movement-1, results, path.dup)
		self.determine_locations(entity_manager, owner, row, col-1,
					movement-1, results, path.dup)
		self.determine_locations(entity_manager, owner, row, col+1,
					movement-1, results, path.dup)
					
		results.uniq
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


