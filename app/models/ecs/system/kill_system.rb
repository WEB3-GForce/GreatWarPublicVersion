require_relative "./system.rb"

=begin
	The KillSystem is responsible for removing entities from the game once
	they have been killed. In short, it checks to see if damageable entities
	are no longer alive. If so, it removes them from the entity manager and
	any hashes they might have belonged to (such as being placed on the
	board, etc.)
=end
class KillSystem < System

	# This function checks an entity to determine whether it has died. If so,
	# it removes the entity completely from the entity_manager. It removes it
	# from the board and then deletes its entry from the entity manager.
	#
	# Arguments
	#   entity_manager = the manager of entities
	#   entity         = the entity to check
	#
	# Returns
	#   nil if the entity can't die or is still alive
	#   A tuple of the form if successful
	#      [entity_id, whether_removed_from_board, owner_if_it_has_one]
	def self.update(entity_manager, entity)
	
		# Entities that can't be damaged can't die.
		if !EntityType.damageable_entity?(entity_manager, entity)
			return nil
		end
		
		health_comp = entity_manager.get_components(entity, HealthComponent).first
		
		if health_comp.alive?
			return nil
		end
	
		removed = MotionSystem.remove_piece(entity_manager, entity)
		owner = nil
		
		if entity_manager.has_components(entity, [OwnedComponent])
			owner = entity_manager.get_components(entity, OwnedComponent).first.owner
		end
		
		entity_manager.delete(entity)
		return [entity, removed, owner]
	end

end
