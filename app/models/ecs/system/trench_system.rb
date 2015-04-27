=begin
	The TrenchSystem is responsible for creating trenches. Units like infantry
	who can build trenches rely upon this code to convert a square to a
	trench.
=end
class TrenchSystem < System

	# Returns an array of locations an entity can convert into a trench.
	# an entity can only make a trench out of what he is standing on.
	#
	# Arguments
	#   entity_manager = the manager of entities
	#   entity         = the entity to check
	#
	# Returns
	#   an array of squares that can be trenched, nil if none.
	def self.trenchable_locations(entity_manager, entity)
		if !EntityType.trench_builder_entity?(entity_manager, entity) ||
		   !EntityType.placed_entity?(entity_manager, entity)
		   return nil
		end
		pos_comp = entity_manager.get_components(entity, PositionComponent).first
		square = entity_manager.board[pos_comp.row][pos_comp.col][0]
		
		return [square] if entity_manager.has_components(square, [MalleableComponent])
		return nil
	end

	# Converts the square the entity is standing on into a trench
	#
	# Arguments
	#   entity_manager = the manager of entities
	#   entity         = the entity to build a trench
	#
	# Returns
	#   an array of the form:
	#     ["trench", the_new_trench_entity_made]
	def self.make_trench(entity_manager, entity)
		if !EntityType.trench_builder_entity?(entity_manager, entity) ||
		   !EntityType.placed_entity?(entity_manager, entity)
		   return nil
		end
		
		pos_comp = entity_manager.get_components(entity, PositionComponent).first
		square = entity_manager.board[pos_comp.row][pos_comp.col][0]
		return nil if !entity_manager.has_components(square, [MalleableComponent])

		entity_manager.delete square
		
		trench = EntityFactory.trench_square(entity_manager)
		entity_manager.add_component(trench,
			PositionComponent.new(pos_comp.row, pos_comp.col))
		entity_manager.board[pos_comp.row][pos_comp.col][0] = trench
		return ["trench", trench]
	end
end


