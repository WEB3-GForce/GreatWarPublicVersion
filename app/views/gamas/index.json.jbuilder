json.array!(@games) do |game|
json.extract! game, :id, :pending, :done
json.url game_url(game, format: :json)
end
