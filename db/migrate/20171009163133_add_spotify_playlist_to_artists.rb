class AddSpotifyPlaylistToArtists < ActiveRecord::Migration[5.1]
  def change
    add_column :artists, :spotify_playlist, :string
  end
end
