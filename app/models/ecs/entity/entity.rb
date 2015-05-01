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

  # This class variable is used for debugging purposes only. It produces
  # a simpler id that is easier to read.
  @debug_id = -1

  # Initializes a new Entity
  #
  # Arguments
  #   string = the value to intialize to the entity, nil for a uuid
  #
  # Postcondition
  #  A new entity is created. It is represented as the string specified or
  #  the uuid string to ensure that each entity is uniquely identifiable.
  def initialize(string=nil)
    string = SecureRandom.uuid if string == nil
    super string
  end

  # Creates a new Entity for debugging
  #
  # Postcondition
  #  A new entity is created with a string much easier to read. Use for
  #  debugging purposes only.
  def self.debug_entity
    entity = Entity.new
    @debug_id += 1
    entity.replace("entity#" + @debug_id.to_s)
  end
end
