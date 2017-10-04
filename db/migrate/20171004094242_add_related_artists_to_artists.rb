class AddRelatedArtistsToArtists < ActiveRecord::Migration[5.1]
  def change
    add_column :artists, :related_artists, :hstore, array: true
  end
end
