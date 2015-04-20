class AddLimitToGamas < ActiveRecord::Migration
  def change
    add_column :gamas, :limit, :int
  end
end
