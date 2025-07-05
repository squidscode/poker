class CreatePlayerRequests < ActiveRecord::Migration[8.0]
  def change
    create_table :player_requests do |t|
      t.string :name

      t.timestamps
    end
  end
end
