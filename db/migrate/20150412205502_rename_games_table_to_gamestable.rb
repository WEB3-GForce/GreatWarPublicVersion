class RenameGamesTableToGamestable < ActiveRecord::Migration
  def change
    rename_table :games, :gamestable
  end
end
