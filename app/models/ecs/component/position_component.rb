require_relative "./component.rb"

=begin
	The PositionComponent denotes the position of an entity on the board.
	For example, if there were a 20x20 board, an entity on the board would
	contain a PositionComponent. The component might specify that the entity
	is on row 5 and column 18. This component is vital to movement systems.
=end
class PositionComponent < Component

	attr_accessor(:row, :col)

	# Initializes a new PositionComponent object
	#
	# Arguments
	#   row = the row index of the entity on the board
	#   col = the column index of the entity on the board
	#
	# Postcondtion
	#   The PositionComponent object is properly initialized
	def initialize(row, col)
		@row = row
		@col = col
	end

	def distance_to(other_position)
		(@row - other_position.row).abs + (@col - other_position.col).abs
	end

  	# Returns a string representation of the component 
	def to_s
		"Position <#{@row}, #{@col}>"
	end
end

