require "./Component.rb"

=begin
  This class specifies a component for entities that contain a 2d grid.
=end
class GridComponent < Component

  def initialize(rows, columns)
    @grid = Array.new(rows) { Array.new(columns) {nil} }
  end
  
  def [](key)
    @grid[key]
  end
  
  def to_s
    "Grid: " + @grid.inspect.to_s.gsub("],", "]\n      ")
  end
  
end

=begin
g = GridComponent.new 4, 8
g[0][0] = 5
puts g[0][0]
puts g
=end