require 'csv'
class Luxury < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  has_many :episodes

  def self.import_corrections
    CSV.foreach("csv_export/luxury_corrections.csv") do |row|
      Luxury.where(name:row[0]).each do |luxury|
        if luxury != nil
          corrected_luxury = Luxury.where(name:row[1]).first_or_create

          episodes = Episode.where(luxury_id: luxury.id)
          episodes.update(luxury_id: corrected_luxury.id)
          luxury.delete if luxury.episodes.count == 0
        end
      end
    end
  end
end
