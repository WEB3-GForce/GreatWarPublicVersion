require_relative "./component.rb"

=begin
	The RangeAttackComponent is responsible for keeping stats pertaining
	to range attacks. In particular, it keeps track of the damage an entity
	will do for a given attack (@attack), the minimum range of the attack
	or the closest distance another entity can be for the opponent to attack
	(@min_range), and the maxmum range of the attack or the furthest away
	another entity can be for the opponent to attack (@max_range).
=end
class RangeAttackComponent < Component

	attr_reader(:attack, :min_range, :max_range)

	# Initializes a new RangeAttackComponent object
	#
	# Arguments
	#   attack    = the amount of damage done for the range attack
	#   min_range = the shortest distance the range attack can be used
	#   max_range = the maximum distance the range attack can be used
	#
	# Postcondtion
	#   The RangeAttackComponent object is properly initialized
	def initialize(attack, min_range, max_range)
		@min_range = 0
		@max_range = 0
		self.attack    = attack
		self.min_range = min_range
		self.max_range = max_range
	end
	
	# Sets attack to a new attack
	#
	# Arguments
	#    attack = the new attack
	#
	# Postcondition
	#   @attack is set to the new attack or 0 if the new attack is negative
	def attack=(attack)
		@attack = [0, attack].max
	end

	# Sets min_range to a new min_range
	#
	# Arguments
	#    range = the new min_range
	#
	# Postcondition
	#   @min_range is set to the new range or 0 if the new range is negative
	#   @max_range is ensured to be greater than or equal to @min_range	
	def min_range=(range)
		@min_range = [0, range].max
		@max_range = [@min_range, @max_range].max
	end

	# Sets max_range to a new max_range
	#
	# Arguments
	#    range = the new max_range
	#
	# Postcondition
	#   @max_range is set to the new range or 0 if the new range is negative
	#   @min_range is ensured to be less than or equal to @max_range	
	def max_range=(range)
		@max_range = [0, range].max
		@min_range = [@min_range, @max_range].min
	end

  	# Returns a string representation of the component 	
	def to_s
		"Range Attack: [attack = #{@attack}, range = #{@min_range}-#{@max_range}]"
	end
end

