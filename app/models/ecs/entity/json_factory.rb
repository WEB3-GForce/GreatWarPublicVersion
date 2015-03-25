#Dir[File.dirname(__FILE__) + '/../component/*.rb'].each {|file| require_relative file }
#Dir[File.dirname(__FILE__) + '/../system/*.rb'].each {|file| require_relative file }
#Dir[File.dirname(__FILE__) + '/./*.rb'].each {|file| require_relative file }
=begin

=end
class JsonFactory

	def self.board_json(entity_manager)
	
		json = Hash.new
		json["response"] = "board"
		board_array = []
		(0...entity_manager.row).each { |row|
			(0...entity_manager.col).each { |col|
				board_array.push self.square_json(entity_manager, entity_manager.board[row][col][0])				
			}
		}
		json["board"] = board_array
		json
	end
	
	def self.square_json(entity_manager, entity)
		terrain_comp = entity_manager.get_components(entity, TerrainComponent).first
		json = Hash.new
		json["terrain"] = terrain_comp.type.to_s
		json
	end

	def self.path_json(entity_manager, path)
		json = Hash.new
		json["response"] = "moveable_locations"
		path_array = []
		path.each { |path_square|
			path_array.push self.square_position_json(entity_manager, path_square)
		}
		json["path"] = path_array
	end

	def self.moveable_locations_json(entity_manager, locations)
		json = Hash.new
		json["response"] = "moveable_locations"
		locations_array = []
		locations.each { |path_square|
			locations_array.push self.square_position_json(entity_manager, path_square)
		}
		json["locations"] = locations_array
	end


	def self.square_position_json(entity_manager, entity)
		pos_comp = entity_manager.get_components(entity, PositionComponent).first
		[pos_comp.x, pos_comp.y]
	end
end

#{ response: "board"
#  locations: [{"terrain": "flatland"}, {"terrain": "river"}]
#}

#{ response: "infantry"
#  locations: [{type = "infantry", x => 0, y => 1}]
#}

#{ method: "moveable_locations"
#  args: [entity_wishing_to_move]
#}
#{ response: "moveable_locations"
#  locations: [[0,1], [0,2], [0,3] ...]
#}
#{ method: "move_piece"
#  args: [entity_to_move, x, y]
#}
#{ response: "move_piece"
#  path: [[0,1], [0,2], [0,3] ...]
#}

