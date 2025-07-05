class AddAuthTokenToPlayer < ActiveRecord::Migration[8.0]
  def change
    add_column :players, :auth_token, :string
    add_index :players, :auth_token, unique: true
  end
end
