class AddPlayersToGamas < ActiveRecord::Migration
  def change
    add_column :gamas, :players, :int
  end
end
