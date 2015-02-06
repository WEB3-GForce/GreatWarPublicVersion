require "Entity.rb"
require "EntityManager.rb"
require File.expand_path("../../component/PassableComponent.rb", __FILE__)


=begin
	This class is a factory for more easily creating entities in an entity
	manager. For entities that typically require the same components to
	be added to them, the factory method handles creating the entity and
	adding the components to them.
=end
class EntityFactory

	def self.tile_flatland(entity_manager)
		entity = entity_manager.create_entity()
		entity_manager.add_component(entity, TerrainComponent.flatland)
		entity_manager.add_component(entity, PassableComponent.new)
		entity_manager.add_component(entity, OccupiableComponent.new)
		return entity
	end
	
	def self.tile_mountain(entity_manager)
		entity = entity_manager.create_entity()
		entity_manager.add_component(entity, TerrainComponent.mountain)
		entity_manager.add_component(entity, OccupiableComponent.new)
		return entity
	end
	
	def self.tile_river(entity_manager)
		entity = entity_manager.create_entity()
		entity_manager.add_component(entity, TerrainComponent.river)
		entity_manager.add_component(entity, PassableComponent.new)
		return entity
	end
	
	def self.board(entity_manager, row, col)
		entity = entity_manager.create_entity()
		entity_manager.add_component(entity, GridComponent.new(row, col))
		return entity
	end

end

manager = EntityManager.new


EntityFactor.tile_flatland(manager)
EntityFactor.tile_mountain(manager)
EntityFactor.tile_river(manager)
EntityFactor.board(manager)

puts manager
