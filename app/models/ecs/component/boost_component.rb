require_relative "./component.rb"

=begin
	The BoostComponent is used to add boosts to terrain. Terrains can hold
	multiple boost components that can have a variety of affects. For example,
	a defense boost would give any units standing on it a boost in defense.
	A move_cost "boost" would increase the energy needed to cross the 
	terrain.
	
	For example, a defense boost of 2 means that attacks will take 1/2 less
	damage. A move_cost of 2 means that it would cost x2 the regular amount
	to move onto it.
=end
class BoostComponent < Component

private
	# Initializes a new BoostComponent object
	#
	# Arguments
	#   type   = the type of boost given.
	#   amount = a ratio of the boost. Boosts should be doubles like 2.0
	#            For example, a 2.0 move_cost means the movement cost is doubled.
	#
	# Postcondtion
	#   The BoostComponent object is properly initialized
	def initialize(type, amount)
		@type = type
		@amount = amount
	end

public

	attr_reader(:type, :amount)

	# These are the static boost objects. If a boost is needed,
	# these should be used. Since they are static, DO NOT MODIFY THESE
	# OUTSIDE THIS FILE.
	@defense        = :defense
	@move_cost      = :move_cost

	# Getter methods for the class instance variables
	def self.defense      ; @defense    ; end
	def self.move_cost    ; @move_cost  ; end

	# Returns a string representation of the component
	def to_s
		"Boost : [Type = #{@type}, Amoung = #{@amount}]"
	end
end

