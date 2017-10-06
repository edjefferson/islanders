class Castaway < ApplicationRecord
  has_many :episodes
  has_many :artists, through: :episodes
  has_many :choices, through: :episodes

  has_and_belongs_to_many :categories

  def self.find_joint_appearances
    Castaway.where("name like '% and %' or name like '% & %' or name like '% Ascension Islands%'")
  end

  def appearances_count
    self.update(appearances: self.episodes.distinct.count)
  end


  def self.update_wikipedia_url
    joint_episodes = Episode.find_joint_appearances.map {|episode| episode.id}
    Castaway.where(wikipedia_url: ["",nil]).each do |castaway|
      urls = Episode.where.not(id: joint_episodes).where.not(wikipedia_url: [nil,""]).where(castaway_id: castaway.id).pluck(:wikipedia_url)
      urls.select{ |url| url.to_s != ""}
      castaway.update(wikipedia_url: urls[0])

    end
  end

  def self.find_duplicates_via_wiki
    joint_episodes = Episode.find_joint_appearances.map {|episode| episode.id}
    episodes = Episode.where.not(id: joint_episodes).where.not(wikipedia_url: [nil,""])
    episodes.each do |episode|
      puts episode.inspect

      castaway_id = episode.castaway.id
      matched_episodes = episodes.where(wikipedia_url: episode.wikipedia_url).where.not(castaway_id: castaway_id)
      if matched_episodes.count > 0
        old_castaway_ids = matched_episodes.pluck(:castaway_id)
        old_castaways = Castaway.where(id: old_castaway_ids)
        episode.castaway.castaway_aliases = [] if episode.castaway.castaway_aliases == nil
        old_castaways.pluck(:name).each { |castaway_alias| episode.castaway.castaway_aliases += [castaway_alias] }
        matched_episodes.update(castaway_id: castaway_id)
        episode.castaway.appearances = episode.castaway.episodes.count
        episode.castaway.save
        old_castaways.delete_all
      end
    end

  end
end
