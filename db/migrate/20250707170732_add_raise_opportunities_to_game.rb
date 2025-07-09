class AddRaiseOpportunitiesToGame < ActiveRecord::Migration[8.0]
  def change
    add_column :games, :raise_opportunities, :integer
  end
end
