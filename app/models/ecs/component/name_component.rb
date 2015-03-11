require_relative "./component.rb"

=begin
	The NameComponent is used to give a name to entities. For example,
	a NameComponent might be given to a player entity to denote the player's
	in game name.
=end

class NameComponent < Component
  
	attr_reader :name

	# Initializes a new NameComponent object
	#
	# Arguments
	#   name = the name of the entity
	#
	# Postcondtion
	#   The NameComponent object is properly initialized
	def initialize(name)
		@name = name
	end

	# Returns a string representation of the component  
	def to_s
		"Name: #{@name}"
	end
end

