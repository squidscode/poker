class RemovePlayerOrderingFromGame < ActiveRecord::Migration[8.0]
  def change
    remove_column :games, :player_ordering
  end
end
