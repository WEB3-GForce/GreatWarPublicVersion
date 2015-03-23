require_relative "./component.rb"

=begin
	The EnergyComponent is responsible for managing a wide range of actions.
	Actions such as movement, attack, and building trenches will have an
	energy cost associated with it. The energy component will track how much
	energy an entity has to expend on such actions.
=end
class EnergyComponent < Component

	attr_reader :cur_energy, :max_energy

	# Initializes a new EnergyComponent object
	#
	# Arguments
	#   max_energy  = the default energy of the entity
	#   cur_energy  = the amount of spaces the entity can currently move
	#
	# Postcondtion
	#   The EnergyComponent object is properly initialized
	def initialize(max_energy, cur_energy=max_energy)
		self.max_energy = max_energy
		self.cur_energy = cur_energy
	end
  
  	# Sets the current energy to a new energy
  	#
  	# Arguments
  	#   energy = the new energy to set current energy to
  	#
  	# Postcondition
  	#   The current energy is set to the new energy or 0 if the new
  	#   energy was negative
	def cur_energy=(energy)
		@cur_energy = [0, energy].max
	end

  	# Sets the max energy to a new energy
  	#
  	# Arguments
  	#   energy = the new energy to set base energy to
  	#
  	# Postcondition
  	#   The max energy is set to the new energy or 0 if the new
  	#   energy was negative
	def max_energy=(energy)
		@max_energy = [0, energy].max
	end


	# Resets the current energy to the max energy.
	def reset
		@cur_energy = @max_energy
	end

	# Whether the entity has energy left to use
	def energized?
		@cur_energy > 0
	end

  	# Returns a string representation of the component  
	def to_s
		"Energy: #{@cur_energy}/#{@max_energy}"
	end

  
end

