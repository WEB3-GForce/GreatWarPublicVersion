require_relative "./entity.rb"
require_relative "./component_bag.rb"

=begin
	The EntityManager is the "database table" of the ecs model. It is
	responsible for mapping entities (rows) to their components (columns).
	The manager provides a quick, efficient way to determine which
	components belong to an entity. It often provides hashes to make it
	fast to determine which entities have a given component.
	
	The EntityManager contains all the game state data for the game. Hence,
	a game can be saved and loaded by marshalling/ unmarshalling the
	EntityManager.
=end
class EntityManager < Hash

	attr_reader(:board, :row, :col)

	# Initializes a new EntityManager
	#
	# Arguments
	#   row = the number of rows that the board will have
	#   col = the number of columns that the board will have
	#
	# Postcondition
	#   the EntityManager is properly initialized
	def initialize(row, col)	
		@row   = row
		@col   = col
		@board = Array.new(row) {Array.new(col)}
		super()
	end


	# Access the value of a given hash creating a new entry if the key
	# is undefined
	#
	# Arguments
	#   entity = the key to access
	#
	# Return
	#   the value of the hash
	#
	# Note
	#   If the key is undefined, attempting to access it will create
	#   the key. Hence, it will be possible to do:
	#
	#      entity_manager[entity][component_class] = ...
	#
	#   Hence, one can add to the component bag and still have the entity
	#   defined.
	#
	#   Keep this in mind that merely accessing an undefined entity now
	#   creates one.
	def [](entity)
		self[entity] = ComponentBag.new if !self.has_key?(entity)
		super
	end

	# Adds a component to an entity.
	#
	# Arguments:
	#	entity    = the entity to add the component to
	#	component = the component to add
	# 
	# Returns:
	#   Whether the component was successfully added
	#
	# Note:
	#   The method is simply syntactic sugar.
	def add_component(entity, component)
		self[entity][component.class].push(component)
	end

	# Gets the components of an entity of a specific class.
	#
	# Arguments:
	#	entity          = the entity to retreive the components from
	#	component_class = the class of the component to retrieve
	# 
	# Returns:
	#   An array (possibly empty) of all the components of the specified
	#   class owned by the entity.
	#
	# Note:
	#   The method is simply syntactic sugar and does not necessarily need
	#   to be used.
	def get_components(entity, component_class)
		self[entity][component_class]
	end
	
	# Returns all entities that contain a given component.
	#
	# Arguments:
	#	*component_class = a list of component classes that the entities
	#                          should have.
	# 
	# Returns:
	#   An array (possibly empty) of all the entities that have the specified
	#   component
	def get_entities_with_components(*component_classes)
		entity_array = []
		self.each do |entity, comp_bag|
			if component_classes.all? {|comp| comp_bag.has_key?(comp) && comp_bag[comp] != []}
				entity_array.push(entity)
			end
		end
		return entity_array
	end

	# An extension of each, yields to a block only those entities that have
	# all the desired component classes.
	#
	# Arguments
	#	*component_class = a list of component classes that the entities
	#                          should have.
	# 
	# Postcondition
	#   all the desired entities have been passed to the block
	def each_entity(*component_classes)
		array = self.get_entities_with_components(*component_classes)
		array.each { |entity| yield entity }
	end

	# For debugging purposes, converts the manager to a string
	def to_s
		string = "EntityManager: {\n"
		self.each { |key, value|
			string += "\t#{key} => #{value}\n"
		}
		string += "\tBoard =>\n"
		@board.each {|row|
			string += "\t\t#{row}\n"
		}
		string += "}\n"
	end
end

