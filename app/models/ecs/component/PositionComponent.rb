require "Component.rb"

=begin
	This class is used to specific a componenet's position on the board.
	The board system is responsible for ensuring that the position is valid
	on the board.
=end
class PositionComponent < Component

	attr_accessor(:row, :col)

	def initialize(row, col)
		@row = row
		@col = col
	end
	
	def to_s
		return "Position <#{@row}, #{@col}>"
	end
end


puts PositionComponent.new(10, 10)
puts PositionComponent.new(281, 201)
