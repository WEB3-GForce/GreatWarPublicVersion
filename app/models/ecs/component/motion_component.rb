require_relative "./component.rb"

=begin
	The MotionComponent records stats that are necessary for movement
	upon a board. The component stores two main stats: the current
	movement of the entity (which denotes how many squares an entity
	can currently move) and the base movement (which denotes the entity's
	original movement status). Current movement could potentially change
	based on status boosts; base movement is used to return the movement
	to normal.
=end
class MotionComponent

	attr_reader :base_movement, :cur_movement

	# Initializes a new MotionComponent object
	#
	# Arguments
	#   base_movement = the default movement of the entity
	#   cur_movement  = the amount of spaces the entity can currently move
	#
	# Postcondtion
	#   The MotionComponent object is properly initialized
	def initialize(base_movement, cur_movement=base_movement)
		self.base_movement = base_movement
		self.cur_movement  = cur_movement
	end
  
  	# Sets the current movement to a new movement
  	#
  	# Arguments
  	#   movement = the new movement to set current movement to
  	#
  	# Postcondition
  	#   The current movement is set to the new movement or 0 if the new
  	#   movement was negative
	def cur_movement=(movement)
		@cur_movement = [0, movement].max
	end

  	# Sets the base movement to a new movement
  	#
  	# Arguments
  	#   movement = the new movement to set base movement to
  	#
  	# Postcondition
  	#   The base movement is set to the new movement or 0 if the new
  	#   movement was negative
	def base_movement=(movement)
		@base_movement = [0, movement].max
	end

	# Whether the entity can move
	def can_move?
		@cur_movement > 0
	end

  	# Returns a string representation of the component  
	def to_s
		"Movement: #{@cur_movement}/#{@base_movement}"
	end

  
end

