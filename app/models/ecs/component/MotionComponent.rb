require_relative "./Component.rb"

=begin
  Contains properties of entities that can move.
=end
class MotionComponent
  
  attr_reader :max_movement, :cur_movement
  
  def initialize(max_movement, cur_movement=max_movement)
    @max_movement = max_movement
    @cur_movement = cur_movement
  end
  
  def cur_movement=(movement)
    @cur_movement = [0, movement].max
  end
  
  def max_movement=(movement)
    @max_movement = [0, movement].max
  end
  
  def can_move?
    @cur_movement > 0
  end
  
  def to_s
    "Movement: #{@cur_movement}/#{@max_movement}"
  end
  
end

=begin
test = MotionComponent.new(4, 2)
puts test
test.cur_movement = 10
test.max_movement = 5
puts test
=end