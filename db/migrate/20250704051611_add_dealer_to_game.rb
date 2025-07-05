class AddDealerToGame < ActiveRecord::Migration[8.0]
  def change
    add_column :games, :dealer, :integer
  end
end
