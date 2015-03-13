require_relative "./component.rb"

=begin
	The TurnComponent is responsible for keeping track of turn information
	for the game. It contains a list of players and keeps track of which
	player's turn it currently is. It also keeps track of entities the
	player has moved, has made attacked, or has made perform a special
	action (such as digging trenches). This ensures that a player can
	not have pieces	act more times than they should be able to.
=end
class TurnComponent < Component

	# Initializes a new TurnComponent object
	#
	# Arguments
	#   players = an array of player entities
	#
	# Postcondtion
	#   The TurnComponent object is properly initialized
	def initialize(players)
		@turn     = 0
		@players  = players
		@moved    = Hash.new {false}
		@attacked = Hash.new {false}
		@special  = Hash.new {false}
	end

	# Returns the player entity whose turn it currently is
	def current_turn()
		@players[@turn]
	end

	# Ends the turn for the current player and moves to the next player's
	# turn.
	#
	# Postcondtion
	#   The old player's turn is ended and the new player now has a turn.
	#   The moved, attacked, and special hashes are reset for the new player
	def next_turn()
		@turn     = (@turn + 1) % @players.size
		@moved    = Hash.new {false}
		@attacked = Hash.new {false}
		@special  = Hash.new {false}
		self.current_turn
	end

	# Denote to the turn entity that a given piece entity has made its move
	#
	# Arguments
	#   entity = the piece that moved
	#
	# Postcondtion
	#   The entity is marked as having moved
	def moved(entity)
		@moved[entity] = true
	end

	# Denote to the turn entity that a given piece entity has attacked
	#
	# Arguments
	#   entity = the piece that attacked
	#
	# Postcondtion
	#   The entity is marked as having attacked
	def attacked(entity)
		@attacked[entity] = true
	end

	# Denote to the turn entity that a given piece has done a special action
	# like digging a trench.
	#
	# Arguments
	#   entity = the piece that made the special action
	#
	# Postcondtion
	#   The entity is marked as having done a special action
	def done_special(entity)
		@special[entity] = true
	end

	# Whether a piece entity has moved
	#
	# Arguments
	#   entity = the entity to examine
	#
	# Return
	#   True if the piece has already moved, false otherwise
	def has_moved?(entity)
		@moved[entity]
	end

	# Whether a piece entity has attacked
	#
	# Arguments
	#   entity = the entity to examine
	#
	# Return
	#   True if the piece has already attacked, false otherwise
	def has_attacked?(entity)
		@attacked[entity]
	end

	# Whether a piece entity has done a special action like digging trenches
	#
	# Arguments
	#   entity = the entity to examine
	#
	# Return
	#   True if the piece has already done a special action, false otherwise
	def has_done_special?(entity)
		@special[entity]
	end


  	# Returns a string representation of the component 
	def to_s
		string = "Turn => #{self.current_turn}, Players => #{@players}, "
		string += "Moved => #{@moved.keys}, Attacked => #{@attacked.keys}, "
		string += "DoneSpecial => #{@special.keys}"
	end
end

