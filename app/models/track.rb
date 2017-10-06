require 'csv'
class Track < ApplicationRecord
  extend FriendlyId
  friendly_id :track, use: :slugged

  belongs_to :artist
  has_many :choices
  has_many :episodes, through: :choices


  def appearances_count
    self.update(appearances: self.choices.distinct.count)
  end

  def self.export
    self.all.each do |track|
      #
    end
  end
end
