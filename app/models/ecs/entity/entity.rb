require "securerandom"

=begin
	Entities are the "rows" of the ecs "database table". They are the
	objects of OOP. When the game needs to create a new object such as a
	player, board piece, infantryman, etc., it will create a new entity
	and add it to the EntityManager ("database table").
	
	The EntityManager will then keep track of the entities as well as their
	attributes. Entities will be given components, which are the "columns"
	of the "database table". In short, an entity is simply a key that maps
	to its list of attributes (components).

	To create a new entity, simply call Entity.new . This will create a
	string with a uuid. Hence, it guarentees that each entity will be
	uniquely identifiable.
=end
class Entity < String

	# Initializes a new Entity
	#
	# Postcondition
	#  A new entity is created. It is represented as a uuid string to ensure
	#  that each entity is uniquely identifiable.
	def initialize
		super SecureRandom.uuid
	end
end
