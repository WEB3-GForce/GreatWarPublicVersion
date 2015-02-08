require_relative "./Component.rb"

=begin
  Contains properties of entities that are 'owned' by another entity.
=end
class OwnedComponent
  
  attr_accessor :owner
  
  def initialize(owner = nil)
    @owner = owner
  end
  
  def put_s
    "Owned by: #{@owner}"
  end
  
end

test = OwnedComponent.new
puts test.owner == nil

test2 = OwnedComponent.new(500)
puts test