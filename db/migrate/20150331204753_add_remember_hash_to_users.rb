class AddRememberHashToUsers < ActiveRecord::Migration
  def change
    add_column :users, :remember_hash, :string
  end
end
