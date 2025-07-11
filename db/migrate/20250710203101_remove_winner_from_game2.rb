class RemoveWinnerFromGame2 < ActiveRecord::Migration[8.0]
  def change
    remove_column :games, :winner
  end
end
