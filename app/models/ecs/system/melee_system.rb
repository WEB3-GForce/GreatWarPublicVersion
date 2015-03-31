require_relative "./system.rb"
require_relative "./damage_system.rb"
require_relative "./motion_system.rb"
require_relative "../entity/entity_type.rb"

=begin
	The MeleeSystem is responsible for coordinating melee attacks. It ensures
	that the entities can properly do battle, that they are within the
	valid range for melee attacks, and then adminsters the damage.
	
	For melee attacks, the entity attacked will return damage if it is
	still alive and can do so.
=end
class MeleeSystem < System

private

	# Determines if it is valid for two entities to melee attack each other.
	#
	# Arguments
	#   entity_manager   = the manager of entities
	#   attacking_entity = the entity attacking
	#   attacked_entity  = the entity being attacked
	#
	# Return
	#   true if attacking_entity can melee attack, attacked_entity can be
	#      damaged, and they are adjacent to each other.
	#   false otherwise.
	def self.valid_melee?(entity_manager, attacking_entity, attacked_entity)
		return EntityType.melee_entity?(entity_manager,  attacking_entity) &&
		   EntityType.damageable_entity?(entity_manager, attacked_entity) &&
		   MotionSystem.adjacent?(entity_manager, attacking_entity, attacked_entity)
	end

	# This function is an internal helper responsible for actually applying
	# the damage to the entities and updating the returned damage array to
	# reflect that a melee attack occurred.
	#
	# Arguments
	#   entity_manager = the manager of entities
	#   attacking_entity = the entity attacking
	#   attacked_entity  = the entity being attacked
	#
	# Returns
	#    The result of DamageSystem.update
	#
	#    If damage is applied, the damage return array will be of the form:
	#
	#	[["melee", damage_info], ...]
	def self.perform_attack(entity_manager, attacking_entity, attacked_entity)
		mattack = entity_manager.get_components(attacking_entity, MeleeAttackComponent).first
		result  = DamageSystem.update(entity_manager, attacked_entity, mattack.attack)
		result[0].unshift "melee" if !result.empty?
		return result
	end

public

	# Gets the locations that an entity can melee attack
	# TODO testing/documentation
	def self.attack_locations(entity_manager, entity)
		if !EntityType.melee_entity?(entity_manager, entity) or 
				!EntityType.placed_entity?(entity_manager, entity)
			return []
		end

		results = []

		pos_comp = entity_manager.get_components(entity, PositionComponent).first
		[[-1, 0], [1, 0], [0, -1], [0, 1]].each { |row_diff, col_diff|
			row = pos_comp.row + row_diff
			col = pos_comp.col + col_diff

			next if row < 0 or row >= entity_manager.row
			next if col < 0 or col >= entity_manager.col

			(square, occupants) = entity_manager.board[row][col]

			next unless occupants.respond_to? :each
			occupants.each { |occ|
				occ_own_comp = entity_manager.get_components(occ, OwnedComponent).first
				results.push square if occ_own_comp.owner != own_comp.owner
			}
		}

		return results
	end

	# This function performs a melee attack. Entity1 attacks entity2. If
	# entity2 is still alive, it will also attack back.
	#
	# Arguments
	#   entity_manager = the manager of entities
	#   entity1        = the entity attacking
	#   entity2        = the entity being attacked
	#
	# Returns
	#   [] if nothing happens
	#   an array of the form
	#
	#	1. if entity1 only attacks
	#	2. if entity1 kills entity2
	#	3. if entity1 and entity2 both attack and live
	#	4. if entity1 and entity2 both attack and entity1 dies
	#
	#	1. [["melee", entity2_damage_info]]
	#	2. [["melee", entity2_damage_info], [entity2_kill_info]]
	#	3. [["melee", entity2_damage_info], ["melee", entity1_damage_info]]
	#	4. [["melee", entity2_damage_info], ["melee", entity1_damage_info], [entity1_kill_info]]
	def self.update(entity_manager, entity1, entity2)
		if !self.valid_melee?(entity_manager, entity1, entity2)
			return []
		end
	
		melee_comp = entity_manager.get_components(entity1, MeleeAttackComponent).first
		if !EnergySystem.enough_energy?(entity_manager, entity1, melee_comp.energy_cost)
			return []
		end
		result = self.perform_attack(entity_manager, entity1, entity2)
		EnergySystem.consume_energy(entity_manager, entity1, melee_comp.energy_cost)
	
		# If entity2 can melee attack and isn't dead, make it attack.
		if self.valid_melee?(entity_manager, entity2, entity1) &&
				result.size != 2
			result.concat self.perform_attack(entity_manager, entity2, entity1)
		end
		
		return result
	end

end
