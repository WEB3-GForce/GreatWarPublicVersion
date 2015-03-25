require_relative "./system.rb"
require_relative "./turn_system.rb"

=begin
	The EnergySystem is responsible for managing the energy of pieces. If
	a piece requires energy to perform an action, the EnergySystem provides
	methods for determining if the entity has enough energy and for updating
	the energy of an entity appropriately.
=end
class EnergySystem < System

	# Determines if an entity has enough energy to perform an action.
	#
	# Arguments
	#   entity_manager = the manager of entities
	#   entity         = the energy entity to check
	#   energy_cost    = how much energy an action will cost
	#
	# Returns
	#   whether the entity has enough energy to perform an action.
	def self.enough_energy?(entity_manager, entity, energy_cost)
		if !EntityType.energy_entity?(entity_manager, entity)
			return false
		end
		energy_comp = entity_manager.get_components(entity, EnergyComponent).first
		return energy_comp.cur_energy >= energy_cost
	end

	# Updates an entity to have used a certain amount of energy
	#
	# Arguments
	#   entity_manager = the manager of entities
	#   entity         = the energy entity
	#   energy_used    = the amount of energy to subtract
	#
	# Postcondition
	#   The EnergyComponent has been modified appropriately. If the entity
	#   is moveable, its motion component is modified appropriately.
	def self.consume_energy(entity_manager, entity, energy_used)

		if !EntityType.energy_entity?(entity_manager, entity)
			return false
		end

		energy_comp = entity_manager.get_components(entity, EnergyComponent).first
		energy_comp.cur_energy -= energy_used
	
		if EntityType.moveable_entity?(entity_manager, entity)
			motion_comp = entity_manager.get_components(entity, MotionComponent).first
			motion_comp.max_movement = energy_comp.cur_energy / motion_comp.energy_cost
		end
		return true
	end

	# Updates an entity to have used a certain amount of energy
	#
	# Arguments
	#   entity_manager = the manager of entities
	#
	# Postcondition
	#   All entities that use energy have had their energies reset.
	def self.reset_energy(entity_manager)
		TurnSystem.current_turn_entities_each(entity_manager) { |entity|
			if EntityType.energy_entity?(entity_manager, entity)
				energy_comp = entity_manager.get_components(entity, EnergyComponent).first
				energy_comp.reset
			end
		}
	end
end
