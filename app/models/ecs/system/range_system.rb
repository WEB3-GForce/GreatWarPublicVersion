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

	# Determines whether an entity has enough energy to atttack
	def self.enough_energy?(entity_manager, entity)
		range_comp = entity_manager.get_components(entity, RangeAttackComponent).first
		cost = range_comp.energy_cost

		return EnergySystem.enough_energy?(entity_manager, entity, cost)
	end

	# Generates entities within a certain range of an entity's position.
	def self.locations_in_range(entity_manager, entity, min_range, max_range)
		pos_comp = entity_manager.get_components(entity, PositionComponent).first
		(-max_range..max_range).each { |col_diff|
			min_diff = [min_range - col_diff.abs, 0].max
			max_diff = max_range - col_diff.abs
			[*(-max_diff..-min_diff), *(min_diff..max_diff)].uniq.each {
					|row_diff|
				row = pos_comp.row + row_diff
				col = pos_comp.col + col_diff

				next if row < 0 or row >= entity_manager.row
				next if col < 0 or col >= entity_manager.col

				(square, occupants) = entity_manager.board[row][col]

				yield square, occupants
			}
		}
	end
	
	# Determines if an attacked entity is within attack range of an attacker.
	def self.in_range?(entity_manager, attacking_entity, attacked_entity)
		distance = MotionSystem.distance(entity_manager, attacking_entity, attacked_entity)

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
	# Returns array of form [["ranged", attacking_entity, damage_info, ...], kill_info...] if successful
	# TODO update tests
	def self.perform_attack(entity_manager, attacking_entity, attacked_entity)
		rattack = entity_manager.get_components(attacking_entity, RangeAttackComponent).first

		splash = rattack.splash
		damages = splash.collect { |n| n * rattack.attack }

		own_comp = entity_manager.get_components(attacking_entity, OwnedComponent).first
		damage_info = []
		kill_info = []
		piece_comp = entity_manager.get_components(attacking_entity, PieceComponent).first
		# Execute damage on targets within ranged attack's splash.
		# Process direct target last in case it is removed via damage system.
		damages.to_enum.with_index.reverse_each { |damage, dist|
			self.locations_in_range(entity_manager, attacked_entity, dist, dist) {
					|square, occupants|
				next unless occupants.respond_to? :each
				occupants.each { |occ|
					occ_own_comp = entity_manager.get_components(occ, OwnedComponent).first
					next if occ_own_comp.owner == own_comp.owner
					result = DamageSystem.update(entity_manager, occ, damage)
					next if result.empty?
					result[0].unshift(piece_comp.type.to_s)
					result[0].unshift(attacking_entity)
					result[0].unshift("ranged")
					damage_info.push result[0]
					kill_info.push result[1] if result[1] != nil
				}
			}
		}

		puts damage_info.to_s
		return [] if damage_info.empty?		
		return damage_info.concat kill_info
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
		if !EntityType.range_entity?(entity_manager, entity) or 
				!EntityType.placed_entity?(entity_manager, entity) or
				!self.enough_energy?(entity_manager, entity)
			return []
		end
		
		range_comp = entity_manager.get_components(entity, RangeAttackComponent).first
		own_comp   = entity_manager.get_components(entity, OwnedComponent).first		
		
		results = []

		self.locations_in_range(entity_manager, entity, 
			range_comp.min_range, range_comp.max_range) { |square, occupants|

			next unless occupants.respond_to? :each
			occupants.each { |occ|
				occ_own_comp = entity_manager.get_components(occ, OwnedComponent).first
				results.push square if occ_own_comp.owner != own_comp.owner
			}
		}

		return results
	end

	# Gets locations that an entity could range attack in theory.
	def self.attackable_range(entity_manager, entity)
		if !EntityType.range_entity?(entity_manager, entity) or 
				!EntityType.placed_entity?(entity_manager, entity) or
				!self.enough_energy?(entity_manager, entity)
			return []
		end

		range_comp = entity_manager.get_components(entity, RangeAttackComponent).first
		
		results = []

		self.locations_in_range(entity_manager, entity, 
			range_comp.min_range, range_comp.max_range) { |square, occupants|

			results.push square if !entity_manager.has_components(square, [ImpassableComponent])
		}

		return results
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
	#   Else an array of the form [["ranged", entit1, entity2_damage_info]] for an
	#   attack that succeeds but does not kill, and
	#   [["ranged", entity1, entity2_damage_info], [entity2_kill_info]] if it does kill.
	#
	def self.update(entity_manager, entity1, entity2)
		if !self.valid_attack?(entity_manager, entity1, entity2)
			return []
		end

		range_comp = entity_manager.get_components(entity1, RangeAttackComponent).first
		if !EnergySystem.enough_energy?(entity_manager, entity1, range_comp.energy_cost)
			return []
		end
		result = self.perform_attack(entity_manager, entity1, entity2)
		EnergySystem.consume_energy(entity_manager, entity1, range_comp.energy_cost)	
		return result
	end

end
