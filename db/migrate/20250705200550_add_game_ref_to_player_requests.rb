class AddGameRefToPlayerRequests < ActiveRecord::Migration[8.0]
  def change
    add_reference :player_requests, :game, null: false, foreign_key: true
  end
end
