require_relative "./component.rb"

=begin
	The ImpassableComponent is used primarily for squares on the board. It
	controls whether it is possible for an entity to move over a given
	square. Its absence denotes that the square is passable. Its presence
	denotes that the square is impassable.
=end
class ImpassableComponent < Component
end
