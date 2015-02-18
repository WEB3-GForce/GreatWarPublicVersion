# =begin
# 	This class is the ancestor of all the system classes. It defines the
# 	update method which other systems should implement.
	
# 	TODO: Determine how to include the entity manager. We could either make
# 	it an instance variable or include it with each call to update. In the
# 	first way, it would make our code less verbose. However, each game
# 	instance running on the server would have its own entity_manager. Hence,
# 	we would need to create a whole new suite of system for each game.
# =end
# class System
# 	def update(entity_manager)
# 		raise NotImplementedError
# 	end
# end

