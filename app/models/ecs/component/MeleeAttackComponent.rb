require_relative "./Component.rb"

=begin
  Contains properties of entities with a melee attack.
=end
class MeleeAttackComponent
  
  attr_reader :attack
  
  def initialize(attack=0)
    self.attack = attack
  end
  
  def attack=(attack)
    @attack = [0, attack].max
  end
  
  def to_s
    "Melee Attack: #{@attack}"
  end
  
end

=begin
test = MeleeAttackComponent.new 5
puts test
test.attack = -5
puts test

Ranged attack: #{@attack}, range: @min - @max
=end