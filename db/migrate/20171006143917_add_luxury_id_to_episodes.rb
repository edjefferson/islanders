class AddLuxuryIdToEpisodes < ActiveRecord::Migration[5.1]
  def change
    add_column :episodes, :luxury_id, :string
    add_index :episodes, :luxury_id
  end
end
