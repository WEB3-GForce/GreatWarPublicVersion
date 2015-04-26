require_relative "./component.rb"

=begin
	The BoostComponent is used to add boosts to terrain. Terrains can hold
	multiple boost components that can have a variety of affects. For example,
	a defense boost would give any units standing on it a boost in defense.
	A move_cost "boost" would increase the energy needed to cross the 
	terrain.
=end
class BoostComponent < Component

private
	# Initializes a new BoostComponent object
	#
	# Arguments
	#   type   = the type of boost given.
	#   percent = a ratio of the boost. For example, 0.5 = 50% boost.
	#
	# Postcondtion
	#   The BoostComponent object is properly initialized
	def initialize(type, percent)
		@type = type
		@percent = percent
	end

public

	attr_reader(:type, :percent)

	# These are the static boost objects. If a boost is needed,
	# these should be used. Since they are static, DO NOT MODIFY THESE
	# OUTSIDE THIS FILE.
	@defense        = BoostComponent.new(:defense,   0.5)
	@move_cost      = BoostComponent.new(:move_cost, 0.5)

	# Getter methods for the class instance variables
	def self.defense      ; @defense    ; end
	def self.move_cost    ; @move_cost  ; end

	# Returns a string representation of the component
	def to_s
		"Boost : [Type = #{@type}, Percent = #{@percent}]"
	end
end

