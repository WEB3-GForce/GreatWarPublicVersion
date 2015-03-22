require_relative "./system.rb"
require_relative "./damage_system.rb"
require_relative "./motion_system.rb"
require_relative "../entity/entity_type.rb"

=begin
	The RangeSystem is responsible for ranged attacks. It finds potential
	targets for units with ranged attack, and validate/execute a ranged attack.
=end
class RangeSystem < System
	
#===============================================================================
private

	# Determines if an attacked entity is within attack range of an attacker.
	def self.in_range?(entity_manager, attacking_entity, attacked_entity)
		distance = MotionSystem.distance(attacking_entity, attacked_entity)

		range_comp = entity_manager.get_components(attacking_entity, RangeAttackComponent).first
		min_range = range_comp.min_range
		max_range = range_comp.max_range

		return distance >= min_range && distance <= max_range
	end

	# Determines if an attack by one entity on another is valid.
	def self.valid_attack?(entity_manager, attacking_entity, attacked_entity)
		return EntityType.range_entity?(entity_manager,  attacking_entity) &&
		   EntityType.damageable_entity?(entity_manager, attacked_entity) &&
		   !EntityType.range_immuned_entity?(entity_manager, attacked_entity) &&
		   self.in_range?(entity_manager, attacking_entity, attacked_entity)
	end

	# Executes a ranged attack.
	# Returns array of form [["ranged", damage_info], ...] if successful
	def self.perform_attack(entity_manager, attacking_entity, attacked_entity)
		rattack = entity_manager.get_components(attacking_entity, RangeAttackComponent).first
		result  = DamageSystem.update(entity_manager, attacked_entity, rattack.attack)
		result[0].unshift "ranged" if !result.empty?
		return result
	end

#===============================================================================
public

	# Get locations that an entity can range attack.
	#
	# Arguments
	#   entity_manager = the manager of the entities
	#   entity         = the entity
	#
	# Returns
	#   An array of square entities the entity can range attack
	#
	# TODO change return to target unit entities?
	#
	def self.attackable_locations(entity_manager, entity)
		if !EntityType.range_entity?(entity_manager, entity)
			return []
		end
		
		range_comp = entity_manager.get_components(entity, RangeAttackComponent).first
		pos_comp   = entity_manager.get_components(entity, PositionComponent).first
		own_comp   = entity_manager.get_components(entity, OwnedComponent).first		
		
		results = []

		min_range = range_comp.min_range
		max_range = range_comp.max_range
		(-max_range..max_range).each { |col_diff|
			min_diff = [min_range - col_diff.abs, 0].max
			max_diff = max_range - col_diff.abs
			[*(-max_diff..-min_diff), *(min_diff..max_diff)].uniq.each {
					|row_diff|
				row = pos_comp.row + row_diff
				col = pos_comp.col + col_diff

				tile      = entity_manager.board[row][col]
				square    = tile[0]
				occupants = tile[1]

				occupants.each { |occ|
					occ_own_comp = entity_manager.get_components(occ, OwnedComponent).first
					results.push square if occ_own_comp.owner != own_comp.owner
				}
			}
		}

		return result
	end

	# Executes a ranged attack from entity1 onto entity2.
	#
	# Arguments
	#   entity_manager = the manager of entities
	#   entity1        = the entity attacking
	#   entity2        = the entity being attacked
	#
	# Returns
	#   [] if nothing happens
	#   Else an array of the form [["ranged", entity2_damage_info]] for an
	#   attack that succeeds but does not kill, and
	#   [["ranged", entity2_damage_info], [entity2_kill_info]] if it does kill.
	#
	def self.update(entity_manager, entity1, entity2)
		if !self.valid_range?(entity_manager, entity1, entity2)
			return []
		end
		
		return self.perform_attack(entity_manager, entity1, entity2)
	end

end