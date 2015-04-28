=begin
	The TrenchSystem is responsible for creating trenches. Units like infantry
	who can build trenches rely upon this code to convert a square to a
	trench.
=end
class TrenchSystem < System

private

	# Determines whether an entity has enough energy to atttack
	#
	# Arguments
	#   entity_manager = the manager of entities
	#   entity         = the entity to check
	#
	# Returns
	#   whether the entity has enough energy
	def self.enough_energy?(entity_manager, entity)
		trench_comp = entity_manager.get_components(entity, TrenchBuilderComponent).first
		cost = trench_comp.energy_cost
		return EnergySystem.enough_energy?(entity_manager, entity, cost)
	end

public

	# Returns an array of locations an entity can convert into a trench.
	#
	# Arguments
	#   entity_manager = the manager of entities
	#   entity         = the entity to check
	#
	# Returns
	#   an array of squares that can be trenched, nil if none.
	def self.trenchable_locations(entity_manager, entity)
		if !EntityType.trench_builder_entity?(entity_manager, entity) ||
		   !EntityType.placed_entity?(entity_manager, entity) ||
		   !self.enough_energy?(entity_manager, entity)
		   return []
		end

      		own_comp = entity_manager.get_components(entity, OwnedComponent).first

		results = []
		pos_comp = entity_manager.get_components(entity, PositionComponent).first
		[[-1, 0], [1, 0], [0, -1], [0, 1]].each { |row_diff, col_diff|
			row = pos_comp.row + row_diff
			col = pos_comp.col + col_diff

			next if row < 0 or row >= entity_manager.row
			next if col < 0 or col >= entity_manager.col

			(square, occupants) = entity_manager.board[row][col]
			next if !entity_manager.has_components(square, [MalleableComponent])
	
			push = true
			occupants.each { |occ|
				occ_own_comp = entity_manager.get_components(occ, OwnedComponent).first
				push = false if occ_own_comp.owner != own_comp.owner
			}
			results.push square if push
		}
		return results
	end

	# Converts the square the entity is standing on into a trench
	#
	# Arguments
	#   entity_manager = the manager of entities
	#   entity         = the entity to build a trench
	#   square         = the square to make a trench
	#
	# Returns
	#   an array of the form:
	#     ["trench", the_new_trench_entity_made]
	def self.make_trench(entity_manager, entity, square)
		if !EntityType.trench_builder_entity?(entity_manager, entity) ||
		   !EntityType.placed_entity?(entity_manager, entity) ||
		   !self.enough_energy?(entity_manager, entity) ||
		   !entity_manager.has_components(square, [MalleableComponent]) ||
		   !self.trenchable_locations(entity_manager, entity).include?(square)
		   return []
		end
		trench_comp = entity_manager.get_components(entity, TrenchBuilderComponent).first
		pos_comp = entity_manager.get_components(square, PositionComponent).first
	
		entity_manager.delete square
		
		trench = EntityFactory.trench_square(entity_manager, 750)
		entity_manager.add_component(trench,
			PositionComponent.new(pos_comp.row, pos_comp.col))
		entity_manager.board[pos_comp.row][pos_comp.col][0] = trench
		EnergySystem.consume_energy(entity_manager, entity, trench_comp.energy_cost)
		return [["trench", trench]]
	end
end


