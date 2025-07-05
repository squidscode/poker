class AddDeckToGame < ActiveRecord::Migration[8.0]
  def change
    add_column :games, :deck, :string
  end
end
