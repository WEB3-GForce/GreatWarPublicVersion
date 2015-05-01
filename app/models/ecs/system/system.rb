=begin
	Systems are the "sql" to the ecs "database tables". While entities
	function as "rows" and components as "columns", systems perform updates
	to the entity_manager. They are responsible for moving objects, causing
	them to attack, managing turns, etc. In short, they are responsible for
	changing the entity_manager to its next state.
	
	Systems should contain NO state of their own and should be able to
	function with any entity_manager. Indeed, a general method will
	look like:
	
		self.method(entity_manager, ....)
	
	Any state that needs to be tracked should either be kept within the
	entity_manager or received as a JSON object.
=end
class System
  # Returns a string representation of the System for easy viewing.
  def to_s
    self.class.name
  end
end


