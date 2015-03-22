require_relative "./system.rb"
require_relative "./damage_system.rb"
require_relative "./motion_system.rb"
require_relative "../entity/entity_type.rb"

class RangeSystem < System
	
#===============================================================================
private

	def self.in_range?(entity_manager, attacking_entity, attacked_entity)
		distance = MotionSystem.distance(attacking_entity, attacked_entity)

		range_comp = entity_manager.get_components(attacking_entity, RangeAttackComponent).first
		min_range = range_comp.min_range
		max_range = range_comp.max_range

		return distance >= min_range && distance <= max_range
	end

	def self.valid_attack?(entity_manager, attacking_entity, attacked_entity)
		return EntityType.range_entity?(entity_manager,  attacking_entity) &&
		   EntityType.damageable_entity?(entity_manager, attacked_entity) &&
		   !EntityType.range_immuned_entity?(entity_manager, attacked_entity) &&
		   self.in_range?(entity_manager, attacking_entity, attacked_entity)
	end

	def self.perform_attack(entity_manager, attacking_entity, attacked_entity)
		rattack = entity_manager.get_components(attacking_entity, RangeAttackComponent).first
		result  = DamageSystem.update(entity_manager, attacked_entity, rattack.attack)
		result[0].unshift "ranged" if !result.empty?
		return result
	end

#===============================================================================
public

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

	def self.update(entity_manager, entity1, entity2)
		if !self.valid_range?(entity_manager, entity1, entity2)
			return []
		end
		
		return self.perform_attack(entity_manager, entity1, entity2)
	end

end