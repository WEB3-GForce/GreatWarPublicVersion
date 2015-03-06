require_relative "Component.rb"

class OccupiableComponent < Component
  
  def to_s
    "Occupiable"
  end
  
end

puts OccupiableComponent.new()

#0,0 => [square_id, [unit1, unit2]]
#0,1 => [river of death, []]
#unit1 addPositionComponent 0,0
#land | River of death| land
