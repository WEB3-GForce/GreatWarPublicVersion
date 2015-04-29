class AddGameToUsers < ActiveRecord::Migration
  def change
    add_column :users, :game, :int
  end
end
