require "securerandom"

require_relative "Entity.rb"

class ComponentBag < Array

    def each_type(class_name)
        self.each { |elem| yield elem if elem.is_a?(class_name) }
    end
end

=begin
	This class is responsible for managing and maintaining entities. It
	contains all the entities in the game along with the components they
	own. It also provides lookup for entities and their components. Since
	this class manages all the data for the game, saving and loading games
	simply consists of saving and loading the EntityManager.
=end
class EntityManager < Hash

	attr_accessor :board, :rows, :columns

	# Initialize a new EntityManager
	def initialize()
		@id = 0
		@components = Hash.new
		@board = Array.new(rows) { Array.new(columns) {nil} }
		super { |hash, key| hash[key] = ComponentBag.new }
	end
	
	# Generates a new, unique, and random id for an entity
	def generate_id()
		Entity.new(@id += 1) # debug
		#Entity.new(SecureRandom.uuid)
   	 end
	
	# Adds entity with value to manager. 
	# A new, unique, random entity is generated if not specified.
  	#
  	# Returns:
  	# 	Added entity's components
	def []=(entity=nil, value)
		entity ||= generate_id()
		super
	end

	# Retrieves an entity.
	# If the entity does not exist, creates it and adds it to the manager.
	# A new, unique, random entity is used if not specified (creating it).
	#
	# Returns:
	# 	Retrieved entity's components
	def [](entity=nil)
		entity ||= generate_id()
		super
	end
    
	# Creates a new entity and inserts it into the hash table.
	# 
	# Returns:
	#   The newly created entity object
	def create_entity()
		id = generate_id()
		self[id] = []
		id
	end

	# Removes an entity from the manager
	# 
	# Arguments:
	#	entity = the entity to delete
	#
	# Postcondition:
	#   The entity is removed from the hash if it was there.
	#
	def delete_entity(entity)
		self.delete(entity)
	end

	# Adds a component to an entity.
	#
	# Arguments:
	#	entity    = the entity to add the component to
	#	component = the component to add
	# 
	# Returns:
	#   Whether the add succeeded (whether the entity is in the hash)
	#
	def add_component(entity, component)
		if !self.has_key?(entity)
			return false
		end
		self[entity].push(component)
		return true
	end

	# Gets the components of an entity of a specific class.
	#
	# Arguments:
	#	entity    = the entity to add the component to
	#	component = the component to add
	# 
	# Returns:
	#   An array (possibly empty) of all the components of the specified
	#   class owned by the entity.
	#
	def get_components(entity, component_class)
		comp_array = []
		self[entity].each do |comp|
			if comp.class == component_class
				comp_array.push(comp)
			end
		end
		return comp_array
	end
	
	# Returns all entities that contain a given component.
	#
	# Arguments:
	#	component_class = the class of the component to get.
	# 
	# Returns:
	#   An array (possibly empty) of all the arrays that have the specified
	#   component
	#
	def get_entities_with_components(component_class)
		entity_array = []
		self.each do |key, value|
			value.each do |comp|
				if comp.class == component_class
					entity_array.push(key)
					break
				end
			end
		end
		return entity_array
	end


	# For debugging purposes, converts the manager to a string
	def to_s()
		string = "EntityManager {\n"
		string += "  Entity Count = " + @entity_count.to_s + "\n"
		string += "  Entity Hash:\n"
		self.each do |key, value|
            string += "    " + key.to_s + " :\n"
		    string += "      ["
		    value.each do |item|
		    	string += item.to_s + ",\n       "
		    end
		    string += "]\n"
		end
		return string + "}\n"
	end
end

=begin

Debugging/testing code.

TODO: Make a formal test suite.
=end

manager = EntityManager.new
ent1 = manager.create_entity()
ent2 = manager.create_entity()
ent3 = manager.create_entity()
puts manager.to_s

manager.add_component(ent1, "I am a component!")
manager.add_component(ent1, "I am a component as well!")
manager.add_component(ent1, "Components are awesome!!")
puts manager.to_s


manager.add_component(ent2, "I am a component!")
manager.add_component(ent2, 20)
manager.add_component(ent2, ent3)
manager.add_component(ent2, ent1)

manager.add_component(ent3, ent2)
manager.add_component(ent3, 25)

puts "Lets test the get_component method!"

manager.get_components(ent2, 1.class).each do |result|
	puts result
end

manager.get_components(ent2, Entity).each do |result|
	puts result
end

manager.get_components(ent2, String).each do |result|
	puts result
end

ent4 = manager.create_entity()
ent5 = ent4

puts manager.to_s

manager.delete_entity(ent5)

puts manager.to_s


puts 1.class.to_s + " rock!"

manager.get_entities_with_components(1.class).each do |result|
	puts result
end

puts "Strings rock!"

manager.get_entities_with_components(String).each do |result|
	puts result
end

puts "Entities rock!"

manager.get_entities_with_components(Entity).each do |result|
	puts result
end

#=end
