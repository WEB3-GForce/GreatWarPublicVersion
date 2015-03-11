require_relative "./component.rb"

=begin
	The MeleeAttackComponent manages stats concerning melee attacks.
	Entities that can launch melee attacks (like infantry) will have a
	MeleeAttackComponent that will specify the amount of damage the entity's
	attack will do.
=end
class MeleeAttackComponent
  
	attr_reader :attack

	# Initializes a new MeleeAttackComponent object
	#
	# Arguments
	#   attack = damage dealt during a melee attack
	#
	# Postcondtion
	#   The MeleeAttackComponent object is properly initialized
	def initialize(attack)
		self.attack = attack
	end
  
	# Sets the melee attack to a new attack
	#
	# Arguments
	#   attack = the new melee attack
	#
	# Postcondition
	#   @attack is set to the new attack or 0 if the new attack was negative
	def attack=(attack)
		@attack = [0, attack].max
	end
  
  	# Returns a string representation of the component
	def to_s
		"Melee Attack: #{@attack}"
	end

end

