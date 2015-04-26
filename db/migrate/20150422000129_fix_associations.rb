class FixAssociations < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.remove :game
      t.belongs_to :gama, index: true
    end

    change_table :gamas do |t|
      t.remove :players
    end
  end
end
