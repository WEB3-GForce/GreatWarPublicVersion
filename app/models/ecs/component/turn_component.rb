require_relative "./component.rb"

=begin
	The TurnComponent is responsible for keeping track of turn information
	for the game. It contains a list of players and keeps track of which
	player's turn it currently is. It also keeps track of the current turn
	count.
=end
class TurnComponent < Component

	attr_accessor :players
	attr_reader   :turn_count

	# Initializes a new TurnComponent object
	#
	# Arguments
	#   player_entities = an array of player entities
	#
	# Postcondtion
	#   The TurnComponent object is properly initialized
	def initialize(player_entities)
		@turn       = 0
		@turn_count = 1
		@players    = player_entities
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
	def next_turn()
		@turn = (@turn + 1) % @players.size
		@turn_count += 1
		self.current_turn
	end

  	# Returns a string representation of the component 
	def to_s
		return "Turn => #{self.current_turn}, Players => #{@players}, "
	end
end

