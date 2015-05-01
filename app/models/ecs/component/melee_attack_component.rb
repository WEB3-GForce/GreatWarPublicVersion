require_relative "./component.rb"
require_relative "./energy_module.rb"

=begin
	The MeleeAttackComponent manages stats concerning melee attacks.
	Entities that can launch melee attacks (like infantry) will have a
	MeleeAttackComponent that will specify the amount of damage the entity's
	attack will do.
=end
class MeleeAttackComponent < Component

  include ENERGY_COST

  attr_reader :attack

  # Initializes a new MeleeAttackComponent object
  #
  # Arguments
  #   attack = damage dealt during a melee attack
  #   energy_cost = the amount of energy used to perform an attack
  #
  # Postcondtion
  #   The MeleeAttackComponent object is properly initialized
  def initialize(attack, energy_cost=1)
    self.attack      = attack
    self.energy_cost = energy_cost
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
    "Melee Attack: [damage = #{@attack}, cost #{self.energy_cost}]"
  end

end

