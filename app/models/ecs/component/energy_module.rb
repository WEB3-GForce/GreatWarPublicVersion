=begin
	This module consolidates all energy-consumption related information.
	Any component that describes an action that requires energy should
	include this module.
=end
module ENERGY_COST
	attr_reader :energy_cost

  	# Sets the energy cost to a new cost
  	#
  	# Arguments
  	#   energy = the new energy to set the cost to
  	#
  	# Postcondition
  	#   The energy_cost has been set to the new energy.
	def energy_cost=(energy)
		@energy_cost= [0, energy].max
	end

end
