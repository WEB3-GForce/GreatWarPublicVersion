=begin
	The ComponentBag is used within the EntityManager. It is responsible for
	storing the different components of an entity. It is a hash of
	component_class => array_of_component_instances. The ComponentBag
	enables code to quickly determine whether an entity has a given
	component.
=end
class ComponentBag < Hash

  # Access the value of a given key creating a new entry if the key
  # is undefined
  #
  # Arguments
  #   component_class = the key to access
  #
  # Return
  #   the value of the hash (aka an array of component instances)
  #
  # Note
  #   If the key is undefined, attempting to access it will create
  #   the key. Hence, it will be possible to do:
  #
  #      bag[component_class] = ...
  #
  #   Hence, one can add to the array and still have the component_class
  #   defined.
  #
  #   Keep this in mind that merely accessing an undefined entity now
  #   creates one.
  def [](component_class)
    self[component_class] = [] if !self.has_key?(component_class)
    super
  end
  
  # Returns a string representation of the component bag
  def to_s 
    string = "ComponentBag: {\n"
    self.each { |key, value|
      string += "\t\t#{key} => #{value}\n"
    }
    string += "\t}\n"
  end
end

