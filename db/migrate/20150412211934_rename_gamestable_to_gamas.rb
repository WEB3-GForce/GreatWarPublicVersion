class RenameGamestableToGamas < ActiveRecord::Migration
  def change
    rename_table :gamestable, :gamas
  end
end
