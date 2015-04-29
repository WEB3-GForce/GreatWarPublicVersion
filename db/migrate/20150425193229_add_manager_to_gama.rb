class AddManagerToGama < ActiveRecord::Migration
  def change
    add_column :gamas, :manager, :text
  end
end
