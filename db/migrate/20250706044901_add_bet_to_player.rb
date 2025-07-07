class AddBetToPlayer < ActiveRecord::Migration[8.0]
  def change
    add_column :players, :bet, :integer
  end
end
