class Artist < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  has_many :discs
  has_many :choices, through: :discs
  has_many :episodes, through: :discs
  has_many :categories, through: :episodes
  has_many :castaways, through: :episodes

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
end
