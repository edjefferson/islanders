class Artist < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  has_many :tracks
  has_many :choices, through: :tracks
  has_many :episodes, through: :tracks

  def update_related_artists
    artist_count = {}
    self.episodes.each do |episode|
      episode.tracks.each do |track|
        if track.artist.name !=""
          artist_count[track.artist.id] == nil ? artist_count[track.artist.id] = 1 : artist_count[track.artist.id] +=1
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
end
