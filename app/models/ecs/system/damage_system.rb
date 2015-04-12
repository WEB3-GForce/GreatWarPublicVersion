require_relative "./kill_system.rb"
require_relative "./system.rb"
require_relative "../entity/entity_type.rb"

=begin
	The DamageSystem is responsible for dealing damage to an entity. It
	applies damage to damageable entities and then calls KillSystem to
	remove the entity if it is dead.
=end

class DamageSystem < System

	# Applies damage to a given entity if it is a damageable entity
	#
	# Arguments
	#   entity_manager = the manager of entities
	#   entity         = the entity to apply damage to
	#   damage         = the amount of damage to apply
	#
	# Returns
	#   [] if the entity is not damageable.
	#   otherwise, returns one of two tuples:
	#
	#       [[entity_damaged, damage_amount]] if entity is alive
	#       [[entity_damaged, damage_amount], [kill_info]] if entity is dead
	#
	# Note
	#   The damage return array should ultimately be of the form:
	#
	#       [[type_of_attack, entity_damaged, damage_amount]]
	#
	#   Other systems that call the DamageSystem (like the MeleeSystem)
	#   should add the type of attack by calling:
	#
	#        result[0].unshift type_of_attack if !result.empty?
	def self.update(entity_manager, entity, damage)
		if !EntityType.damageable_entity?(entity_manager, entity)
			return []
		end
		
		health = entity_manager.get_components(entity, HealthComponent).first
		health.cur_health -= damage
		
		result = KillSystem.update(entity_manager, entity)
		return [[entity, damage]].concat result
	end
end
