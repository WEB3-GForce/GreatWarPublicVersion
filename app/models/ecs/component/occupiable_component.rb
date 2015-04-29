require_relative "./component.rb"

=begin
	The OccupiableComponent is a component for squares on a board. It
	denotes whether other entities can move to a given square. For example,
	there may be squares such as rivers that entities can not stand in
	at the end of the turn (though they still might be able to pass through
	the river)
=end
class OccupiableComponent < Component  
end

