class AddWikipediaUrlToEpisodes < ActiveRecord::Migration[5.1]
  def change
    add_column :episodes, :wikipedia_url, :string
  end
end
