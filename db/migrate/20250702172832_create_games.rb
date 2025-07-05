class CreateGames < ActiveRecord::Migration[8.0]
  def change
    create_table :games do |t|
      t.string :auth_token
      t.string :name
      t.string :player_ordering
      t.integer :active_player
      t.string :community_cards
      t.integer :pot

      t.timestamps
    end
  end
end
