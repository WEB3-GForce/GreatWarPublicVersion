require 'json'

require_relative "entity/EntityManager.rb"
require_relative "entity/EntityFactory.rb"
require_relative "component/GridComponent.rb"
require_relative "component/NameComponent.rb"
require_relative "component/MotionComponent.rb"
require_relative "component/PositionComponent.rb"
require_relative "component/OwnedComponent.rb"

=begin
	A Game represents a game instance the The Great War, with players, units, etc.
=end
class Game
	attr_reader :entity_manager, :systems
	
	# Creates new entity manager and associated systems
	def initialize()
		@entity_manager = EntityManager.new
		@systems = [] # TODO add systems need for game
		
		initialize_entities()
	end
	
	# Processes a request object
	def process(request)
		raise NotImplementedError
	end
	
	def get_board()
        squares = Hash.new
        
        grid = @entity_manager.get_components(@board_entity, GridComponent)[0]
        grid.grid.each { |row_array|
            row_array.each { |element|
                pos = @entity_manager.get_components(element, PositionComponent)[0]
                unit = @entity_manager.get_components(element, OccupiableComponent)[0]
                squares[pos.row.to_s+','+pos.col.to_s] = {
                    'row' => pos.row,
                    'col' => pos.col,
                    'unit' => unit.occupier
                }
            }
        }
        
        squares.to_json
	end
	
	def select_entity(id)
        squares = Hash.new 
        
        posComp = @entity_manager.get_components(id, PositionComponent)
        motComp = @entity_manager.get_components(id, MotionComponent)
        unless posComp == []
            squares[posComp[0].row.to_s+','+posComp[0].col.to_s] = {
                'row' => posComp[0].row,
                'col' => posComp[0].col,
            }
        end
        unless motComp == [] or posComp == []
            row = posComp[0].row
            col = posComp[0].col
            dist = motComp[0].cur_movement
            
            (-dist..dist).each { |n|
                (-dist..dist).each { |m|
                    next if (n == 0 and m == 0)
                    next if (n.abs + m.abs > dist)
                    cur_row = row + n
                    cur_col = col + m
                    next if (cur_row < 0 or cur_col < 0)
                    next if (cur_row >= 3 or cur_col >= 3) # WARNING: hack
                    squares[cur_row.to_s+','+cur_col.to_s] = {
                        'row' => cur_row,
                        'col' => cur_col,
                    }
                }
            }
        end
        
        squares.to_json
	end
	
	def move_entity(id, row, col)
        squares = Hash.new 
        p id, row, col
        posComp = @entity_manager.get_components("11", PositionComponent)
        motComp = @entity_manager.get_components(id, MotionComponent)
        
        return squares if motComp == [] or posComp == []
        
        cur_row = posComp[0].row
        cur_col = posComp[0].col
        max_dist = motComp[0].cur_movement
        
        return squares if (cur_row - row).abs + (cur_col - col).abs > max_dist
        
        grid = @entity_manager.get_components(@board_entity, GridComponent)[0]
        
        occ = @entity_manager.get_components(grid[posComp[0].row][posComp[0].col], OccupiableComponent)[0]
        occ.occupier = nil
        squares[posComp[0].row.to_s+','+posComp[0].col.to_s] = {
            'row' => posComp[0].row,
            'col' => posComp[0].col,
            'unit' => nil
        }

        posComp[0].row = row
        posComp[0].col = col
        
        occ = @entity_manager.get_components(grid[posComp[0].row][posComp[0].col], OccupiableComponent)[0]
        occ.occupier = id
        squares[posComp[0].row.to_s+','+posComp[0].col.to_s] = {
            'row' => posComp[0].row,
            'col' => posComp[0].col,
            'unit' => id
        }
        
	end
	
private
    def initialize_entities()
        # Create board
		board = @entity_manager.create_entity()
		@board_entity = board
		grid = GridComponent.new(3, 3)
		        
        # Create tiles
        3.times { |row|
            3.times { |col|
                sq = @entity_manager.create_entity()
                @entity_manager.add_component(sq, PositionComponent.new(row, col))
                @entity_manager.add_component(sq, OccupiableComponent.new())
                grid[row][col] = sq
            } 
        }
        
        @entity_manager.add_component(board, grid)
        
        # Create players
        2.times { |player_num|
            player = @entity_manager.create_entity()
            @entity_manager.add_component(player, NameComponent.new("Player "+player.to_s))
            
            # Create units
            unit = @entity_manager.create_entity()
            @entity_manager.add_component(unit, MotionComponent.new(2))
            @entity_manager.add_component(unit, PositionComponent.new(player_num, player_num))
            @entity_manager.add_component(unit, OwnedComponent.new(player))
            occ = @entity_manager.get_components(grid[0][player_num], OccupiableComponent)[0]
            occ.occupier = unit
        }
    end
end

g = Game.new
p 'begin'
p g
puts
puts g.get_board()
puts
puts g.select_entity("11")
puts
puts g.move_entity("ll", 2, 2)
puts g.move_entity("ll", 0, 1)
puts g.move_entity("11", 1, 1)
puts g.move_entity("11", 1, 2)
puts
puts g.get_board()
