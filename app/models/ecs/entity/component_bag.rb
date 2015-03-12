=begin
	The ComponentBag is used within the EntityManager. It is responsible for
	storing the different components of an entity. It is a hash of
	component_class => array_of_component_instances. The ComponentBag
	enables code to quickly determine whether an entity has a given
	component.
=end
class ComponentBag < Hash

	# Initializes a new ComponentBag
	#
	# Postcondition
	#  A new ComponentBag is created with a default of []
	def initialize()
		super { [] }
	end
end
