class AddGameRefToPlayer < ActiveRecord::Migration[8.0]
  def change
    add_reference :players, :game, null: false, foreign_key: true
  end
end
