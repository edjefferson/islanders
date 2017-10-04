class Castaway < ApplicationRecord
  has_many :episodes
  has_and_belongs_to_many :wiki_occupations

  def self.find_joint_appearances
    Castaway.where("name like '% and %' or name like '% & %' or name like '% Ascension Islands%'")
  end

  def self.find_duplicates_via_wiki
    castaways = Castaway.where.not("name like '% and %' or name like '% & %' or name like '% Ascension Islands%'").includes(:episodes)
    episodes = castaways.map(&:episodes).flatten
    episodes.each do |episode|
      matched_episodes = Episode.where(wikipedia_url: episode.wikipedia_url).where.not(castaway_id: episode.castaway_id)
      if matched_episodes.count > 0
        old_castaway_ids = matched_episodes.pluck(:castaway_id)
        old_castaways = Castaway.where(id: old_castaway_ids)
        puts episode.inspect
        puts "MATCHING"
        puts matched_episodes.inspect
        puts old_castaways.inspect

        sleep 5
      end
    end

  end
end
