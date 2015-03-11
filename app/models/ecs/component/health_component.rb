require_relative "./component.rb"

=begin
	The HealthComponent is used for entities that have hit points and can
	sustain damage. The component keeps track of the current and maximum
	health of the entity and can determine whether the entity is alive.
	
	For example, a unit such as an infantry piece would have a
	HealthComponent, which would keep track of the amount of damage it has
	taken thus far. When its health reaches 0, it would be removed from the
	game.
=end
class HealthComponent < Component

	attr_reader(:max_health, :cur_health)

	# Initializes a new HealthComponent object
	#
	# Arguments
	#   max_health = the maximum health the entity can have
	#   cur_health = the current health of the entity (usually starts at
	#                max_health)
	#
	# Postcondtion
	#   The HealthComponent object is properly initialized
	def initialize(max_health, cur_health=max_health)
		@max_health = 0
		@cur_health = 0
		# Use the setter methods to make sure max and cur health are
		# set properly.
		self.max_health = max_health
		self.cur_health = cur_health
	end

	# Sets the current health to a new health
	#
	# Arguments
	#   health = the new current health
	#
	# Postcondition
	#   cur_health is equal to health but is made to be between 0 and
	#   @max_health
	def cur_health=(health)
		@cur_health = [[health, 0].max, @max_health].min
	end

	# Sets the max_health to a new max
	#
	# Arguments
	#   health = the new max health
	#
	# Postcondition
	#   max_health is set to the new health, but is made to always
	#     be positive
	#   cur_health is increased or decreased appropriately maintaining
	#     the difference between it and max_health (unless max_health
	#     decreases, in which case it only assures cur_health <= max_health)
	def max_health=(health)
		diff        = [health - @max_health, 0].max
		@max_health = [health, 0].max
		@cur_health = [@cur_health + diff, @max_health].min
	end
	
	# Returns whether or not the entity is alive
	def alive? ; cur_health > 0 ; end
	
	# Returns a string representation of the component
	def to_s ;"Health : #{@cur_health}/#{@max_health}" ; end
end

