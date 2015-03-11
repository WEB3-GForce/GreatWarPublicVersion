=begin
	This is the base class for ecs components. 
	
	Components can be considered the "columns" of the ecs "database table".
	Components encapsulate different attributes and features that an entity
	can have. For example, there might be a HealthComponent for entities
	that have health, a MotionComponent for entities that can move, or an
	AIComponent for entities that are controlled by artificial intelligence.
	
	The entity "rows" can simply choose which components they would
	like to have as "columns". The EntityManager will handle mapping
	entities to their components.
	
	All components will inherit from this class.
=end
class Component
	
	# A default to_s, simply return the name of the component. Children who
	# define major state should override this.
	def to_s
		self.class.name
	end
end
