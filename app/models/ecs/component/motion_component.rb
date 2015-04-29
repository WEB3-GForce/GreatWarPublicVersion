require_relative "./component.rb"
require_relative "./energy_module.rb"

=begin
	The MotionComponent handles stats necessary for movement.
=end
class MotionComponent < Component
	
	include ENERGY_COST

	attr_reader :max_movement

	# Initializes a new MotionComponent object
	#
	# Arguments
	#   max_movement = the maximum reach of the entity
	#   energy_cost  = the amount of energy a single movement takes
	#
	# Postcondtion
	#   The MotionComponent object is properly initialized
	def initialize(max_movement, energy_cost=1)
		self.max_movement  = max_movement
		self.energy_cost   = energy_cost
	end

  	# Sets the max movement to a new movement
  	#
  	# Arguments
  	#   movement = the new movement to set max movement to
  	#
  	# Postcondition
  	#   The max movement is set to the new movement or 0 if the new
  	#   movement was negative
	def max_movement=(movement)
		@max_movement = [0, movement].max
	end

	# Whether the entity can move
	def can_move?
		@max_movement > 0
	end

  	# Returns a string representation of the component  
	def to_s
		"Movement: [amount = #{@max_movement}, cost = #{self.energy_cost}]"
	end

  
end

