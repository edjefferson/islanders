class Book < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  has_many :episodes
end
