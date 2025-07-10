class AddKickStatusToPlayer < ActiveRecord::Migration[8.0]
  def change
    add_column :players, :kick, :integer
  end
end
