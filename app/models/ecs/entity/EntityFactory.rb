require "enumerable/standard_deviation"
require "rubystats"
require_relative "Entity.rb"
require_relative "EntityManager.rb"
#Dir["../../component/*.rb"].each {|file| puts file; require_relative file }
require_relative "../component/TerrainComponent.rb"
require_relative "../component/OccupiableComponent.rb"
require_relative "../component/ImpassableComponent.rb"
require_relative "../component/GridComponent.rb"

=begin
	This class is a factory for more easily creating entities in an entity
	manager. For entities that typically require the same components to
	be added to them, the factory method handles creating the entity and
	adding the components to them.
=end
class EntityFactory

private
	def self.generate_entity(entity_manager, components)
		entity = entity_manager.create_entity()
		components.each do |component|
			entity_manager.add_component(entity, component)
		end
		return entity
	end

public

	def self.tile_flatland(entity_manager)
		return self.generate_entity(entity_manager,
					    [TerrainComponent.flatland,
					    OccupiableComponent.new])
	end
	
	def self.tile_mountain(entity_manager)
		return self.generate_entity(entity_manager,
					    [TerrainComponent.mountain,
					    ImpassableComponent.new])
	end
	
	def self.tile_river(entity_manager)
		return self.generate_entity(entity_manager,
					    [TerrainComponent.river])
	end
	

	def self.board1(entity_manager, clutter=0.25)	
		0.upto(n-1).each {|i|
			0.upto(n-1).each {|j|
				entity_manager.board[i][j] = self.tile_flatland(entity_manager)
			}
		}

		r = Random.new
		# We define probability 0 to be "no clutter", vs. n to be
		# "completely cluttered"
		n = max(entity_manager.rows, entity_manager.columns)
		gen = Rubystats::BinomialDistribution.new(n, clutter)
		gen.times {
			# Now we populate the board with random numbers
			randomi = r.rand(entity_manager.rows)
			randomj = r.rand(entity_manager.columns)

			random_Component = get_random()

			entity_manager.board[randomi][randomj].type = random_Component
		}





	end

	def get_random()
	  case rand(100) + 1
	    when  1..50   then TerrainComponent.mountain
	    when 50..100   then TerrainComponent.river
	end
end

end

manager = EntityManager.new


EntityFactory.tile_flatland(manager)
EntityFactory.tile_mountain(manager)
EntityFactory.tile_river(manager)
EntityFactory.board(manager, 10, 10)

puts manager
