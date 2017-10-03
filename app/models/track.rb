class Track < ApplicationRecord
  extend FriendlyId
  friendly_id :track, use: :slugged

  belongs_to :artist
  has_many :choices
  has_many :episodes, through: :choices
end
