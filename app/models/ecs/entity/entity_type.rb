require_relative "./entity.rb"
require_relative "./entity_manager.rb"

require_relative "../component/ai_component.rb"
require_relative "../component/human_component.rb"
require_relative "../component/melee_attack_component.rb"
require_relative "../component/motion_component.rb"
require_relative "../component/name_component.rb"
require_relative "../component/piece_component.rb"
require_relative "../component/range_attack_component.rb"
require_relative "../component/range_attack_immunity_component.rb"
require_relative "../component/terrain_component.rb"
require_relative "../component/turn_component.rb"

=begin
	The EntityType provides some syntatic sugar for different System classes.
	It provides several methods that determine whether an entity is of a
	certain type. For example, human_player_entity? would query an entity_manager
	to determine if the entity has the components required for it to be
	considered a human player.
=end
class EntityType

	# Determines whether the entity is a square of a board
	#
	# Arguments
	#   entity_manager = the manager that holds the entities
	#   entity         = the entity to check
	#
	# Returns
	#   whether the entity is a square
	def self.square_entity?(entity_manager, entity)
		entity_manager.has_components(entity, [TerrainComponent])
	end

	# Determines whether the entity is a human player
	#
	# Arguments
	#   entity_manager = the manager that holds the entities
	#   entity         = the entity to check
	#
	# Returns
	#   whether the entity is a human player
	def self.human_player_entity?(entity_manager, entity)
		entity_manager.has_components(entity, [NameComponent,
		                                       HumanComponent])
	end

	# Determines whether the entity is an ai player
	#
	# Arguments
	#   entity_manager = the manager that holds the entities
	#   entity         = the entity to check
	#
	# Returns
	#   whether the entity is an ai player
	def self.ai_player_entity?(entity_manager, entity)
		entity_manager.has_components(entity, [NameComponent,
		                                       AIComponent])
	end

	# Determines whether the entity controls the turn information
	#
	# Arguments
	#   entity_manager = the manager that holds the entities
	#   entity         = the entity to check
	#
	# Returns
	#   whether the entity is a turn entity
	def self.turn_entity?(entity_manager, entity)
		entity_manager.has_components(entity, [TurnComponent])
	end

	# Determines whether the entity is a piece on the board such as
	# infantry, machine_gun, artillery, or command_bunker.
	#
	# Arguments
	#   entity_manager = the manager that holds the entities
	#   entity         = the entity to check
	#
	# Returns
	#   whether the entity is a piece
	def self.piece_entity?(entity_manager, entity)
		entity_manager.has_components(entity, [PieceComponent])
	end

	# Determines whether the entity uses energy. Energy is used to control
	# movement, attack, etc.
	#
	# Arguments
	#   entity_manager = the manager that holds the entities
	#   entity         = the entity to check
	#
	# Returns
	#   whether the entity uses energy
	def self.energy_entity?(entity_manager, entity)
		entity_manager.has_components(entity, [EnergyComponent])
	end

	# Determines whether the entity is placed on the board. Namely it needs
	# to have a position.
	#
	# Arguments
	#   entity_manager = the manager that holds the entities
	#   entity         = the entity to check
	#
	# Returns
	#   whether the entity is a placed entity
	def self.placed_entity?(entity_manager, entity)
		entity_manager.has_components(entity, [PositionComponent])
	end

	# Determines whether the entity can move. Namely, it needs to
	# have both a position on the board and a MotionComponent specifying
	# how it can move.
	#
	# Arguments
	#   entity_manager = the manager that holds the entities
	#   entity         = the entity to check
	#
	# Returns
	#   whether the entity is a moveable entity
	def self.moveable_entity?(entity_manager, entity)
		entity_manager.has_components(entity, [EnergyComponent,
		                                       MotionComponent,
		                                       PositionComponent])
	end


	# Determines whether the entity is capable of performing melee attacks
	#
	# Arguments
	#   entity_manager = the manager that holds the entities
	#   entity         = the entity to check
	#
	# Returns
	#   whether the entity is a melee entity
	def self.melee_entity?(entity_manager, entity)
		entity_manager.has_components(entity, [MeleeAttackComponent])
	end

	# Determines whether the entity can take damage (aka be attacked)
	#
	# Arguments
	#   entity_manager = the manager that holds the entities
	#   entity         = the entity to check
	#
	# Returns
	#   whether the entity is a damageable entity
	def self.damageable_entity?(entity_manager, entity)
		entity_manager.has_components(entity, [HealthComponent])
	end

	# Determines whether the entity is capable of performing range attacks
	#
	# Arguments
	#   entity_manager = the manager that holds the entities
	#   entity         = the entity to check
	#
	# Returns
	#   whether the entity is a range attack entity
	def self.range_entity?(entity_manager, entity)
		entity_manager.has_components(entity, [RangeAttackComponent])
	end

	# Determines whether the entity is impervious to range attacks
	#
	# Arguments
	#   entity_manager = the manager that holds the entities
	#   entity         = the entity to check
	#
	# Returns
	#   whether the entity is a range immuned entity
	def self.range_immuned_entity?(entity_manager, entity)
		entity_manager.has_components(entity, [RangeAttackImmunityComponent])
	end
end
