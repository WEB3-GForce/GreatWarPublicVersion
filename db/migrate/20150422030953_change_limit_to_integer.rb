class ChangeLimitToInteger < ActiveRecord::Migration
  def change
    change_column :gamas, :limit, :integer
  end
end
