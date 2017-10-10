require 'csv'

class Category < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  has_and_belongs_to_many :castaways, -> { distinct }
  has_many :episodes, through: :castaways
  has_many :artists, through: :castaways
  has_many :choices, through: :castaways

  def self.import
    CSV.foreach("csv_export/categories.csv") do |row|
      wiki_category = row[0]
      count = row[1]
      if row[2] != nil
        categories = row[2..-1].map { |cat_name| Category.where(name: cat_name).first_or_create }
        castaways = Castaway.joins(:wiki_categories).where("wiki_categories.name like ?", row[0])

        castaways.each do |castaway|
          categories.each { |category| castaway.categories << category if castaway.categories.include?(category) == false }
        end
      end
    end
  end
end
