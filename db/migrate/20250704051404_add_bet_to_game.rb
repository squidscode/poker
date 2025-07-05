class AddBetToGame < ActiveRecord::Migration[8.0]
  def change
    add_column :games, :bet, :integer
  end
end
