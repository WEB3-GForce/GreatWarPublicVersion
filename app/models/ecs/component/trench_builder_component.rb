require_relative "./component.rb"
require_relative "./energy_module.rb"

=begin
	The TrenchBuilderComponent specifies whether an entity can build
	trenches. It also specifies the amount of energy required to do so.
=end
class TrenchBuilderComponent < Component

	include ENERGY_COST

	# Initializes a new TrenchBuilderComponent object
	#
	# Arguments
	#   energy_cost = the amount of energy used to dig a trench
	#
	# Postcondtion
	#   The TrenchBuilderComponent object is properly initialized
	def initialize(energy_cost=1)
		self.energy_cost = energy_cost
	end
  
  	# Returns a string representation of the component
	def to_s
		"Trench Builder: cost #{self.energy_cost}]"
	end

end

