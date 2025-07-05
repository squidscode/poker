class CreatePlayers < ActiveRecord::Migration[8.0]
  def change
    create_table :players do |t|
      t.string :name
      t.integer :chips
      t.string :hole_cards

      t.timestamps
    end
  end
end
