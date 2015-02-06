class GridComponent
  
  attr_reader :grid
  
  def initialize(rows, columns)
    @grid = Array.new(rows) { Array.new(columns) {0} }
  end
  
  def to_s
    "Grid: " + @grid.inspect.to_s.gsub("],", "]\n      ")
  end
  
end

g = GridComponent.new 4, 8
g.grid[0][0] = 5
puts g.grid[0][0]
puts g