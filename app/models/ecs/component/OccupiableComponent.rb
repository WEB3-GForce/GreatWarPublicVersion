require_relative "Component.rb"

class OccupiableComponent < Component
  
  attr_accessor :occupier
  
  def initialize()
    @occupier = nil
  end
  
  def to_s
    "Occupier: #{@occupier}"
  end
  
end

puts OccupiableComponent.new()
