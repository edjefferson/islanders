
class Artist < ApplicationRecord
  include SpotifyPlaylists
  extend FriendlyId
  friendly_id :name, use: :slugged

  has_many :discs
  has_many :choices, through: :discs
  has_many :episodes, through: :discs
  has_many :categories, through: :episodes
  has_many :castaways, through: :episodes
  has_and_belongs_to_many :genres

  def appearances_count
    self.update(appearances: self.choices.distinct.count)
  end

  def category_count(category)
    self.castaways.joins(:categories).where('categories.id = ?',category).count
  end

  def update_related_artists
    artist_count = {}
    self.episodes.includes(:discs).each do |episode|
      episode.discs.each do |disc|
        if disc.artist.name !=""
          artist_count[disc.artist.id] == nil ? artist_count[disc.artist.id] = 1 : artist_count[disc.artist.id] +=1
        end
     end
    end
    artists = artist_count.sort_by { |id, count| - count }[1..5].select { |x| x[1] > 1}
    related_artists = artists.map { |artist| {id: artist[0], appearances: artist[1]} }
    self.update(related_artists: related_artists)
  end

  def related_artists_list
    if self.related_artists == nil
      self.update_related_artists
    end
    self.related_artists
  end

  def generate_spotify_playlist
    top_tracks = self.discs.order(appearances: :desc, name: :asc).limit(20)
    spotify_tracks = top_tracks.map do |track|
      result = self.search_spotify_tracks(track.name, self.name, "track")[0]
      result["uri"] if result != nil
    end

    if spotify_playlist == nil
      playlist_uri = self.create_spotify_playlist("islandersdid", "Islanders - #{self.name}", true)
      self.update(spotify_playlist: playlist_uri)
    end
    self.replace_spotify_playlist("islandersdid", self.spotify_playlist, spotify_tracks)

  end

  def get_spotify_genres

    safe_name = I18n.transliterate(self.name)
    safe_name = safe_name[4..-1] if safe_name[0..3] == "Sir "
    safe_name = "Pyotr Ilyich Tchaikovsky" if safe_name[0..3] == "Peter Ilich Tchaikovsky"
    spotify_api = SpotifyPlaylists.new
    results = spotify_api.search_spotify_tracks(nil, safe_name, "artist")
    puts self.name
    puts "aaa"
    puts results
    if results.count > 0
      exact_matches = results.select { |result| result["name"].downcase == safe_name.downcase }
      puts exact_matches.count
      puts "\n\n\n"
      if exact_matches.count > 0
        genres = exact_matches[0]["genres"].map { |genre| Genre.where(name: genre).first_or_create}
      else
        genres = results[0]["genres"].map { |genre| Genre.where(name: genre).first_or_create}
        puts genres

      end
      self.genres = genres
    end
  end

  def self.import_corrections
    CSV.foreach("csv_export/artist_corrections.csv") do |row|
      puts row
      original_artist = Artist.find_by(name: row[0])
      puts original_artist
      if original_artist
        new_artist = Artist.where(name: row[1].strip).first_or_create
        discs = Disc.where(artist_id: original_artist.id)
        discs.update_all(artist_id: new_artist.id)
        original_artist.delete if original_artist.discs.count == 0
      end
    end
  end
end
