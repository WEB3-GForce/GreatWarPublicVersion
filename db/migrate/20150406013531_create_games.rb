class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.boolean :pending
      t.boolean :done

      t.timestamps null: false
    end
  end
end
