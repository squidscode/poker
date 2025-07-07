class AddAuthTokenToPlayerRequests < ActiveRecord::Migration[8.0]
  def change
    add_column :player_requests, :auth_token, :string
    add_index :player_requests, :auth_token, unique: true
  end
end
