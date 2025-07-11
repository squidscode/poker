class AddWinnersToGame < ActiveRecord::Migration[8.0]
  def change
    add_column :games, :winners, :string
  end
end
