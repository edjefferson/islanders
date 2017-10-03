class Artist < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  has_many :tracks
  has_many :choices, through: :tracks
  has_many :episodes, through: :tracks

  def related_artists
    artist_count = {}
    self.episodes.each do |episode|
      episode.tracks.each do |track|
        if track.artist.name !=""
          artist_count[track.artist.id] == nil ? artist_count[track.artist.id] = 1 : artist_count[track.artist.id] +=1
        end
     end
    end
    artist_count.sort_by { |id, count| - count }[1..5]
  end
end
