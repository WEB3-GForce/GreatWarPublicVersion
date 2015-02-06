require_relative "Component.rb"

class NameComponent < Component
  
  attr_reader :name
  
  def initialize(name)
    @name = name
  end
  
  def to_s
    "Name: " + @name
  end
  
end