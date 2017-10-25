class AddOfflineCacheToEpisode < ActiveRecord::Migration[5.1]
  def change
    add_column :episodes, :offline_cache, :boolean, default: false
  end
end
