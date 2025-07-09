class AddFoldToPlayer < ActiveRecord::Migration[8.0]
  def change
    add_column :players, :fold, :integer
  end
end
