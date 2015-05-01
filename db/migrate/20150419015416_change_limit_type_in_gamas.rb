class ChangeLimitTypeInGamas < ActiveRecord::Migration
  def change
    change_column :gamas, :limit, :string
  end
end
