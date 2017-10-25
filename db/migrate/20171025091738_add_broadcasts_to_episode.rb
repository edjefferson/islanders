class AddBroadcastsToEpisode < ActiveRecord::Migration[5.1]
  def change
    add_column :episodes, :broadcasts, :date, array: true
  end
end
