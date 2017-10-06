require 'open-uri'
require 'csv'

class Category < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  has_and_belongs_to_many :castaways
  has_many :episodes, through: :castaways
  has_many :artists, through: :castaways
  has_many :choices, through: :castaways

  scope :ordered, -> { includes(:availabilities).order('availabilities.price') }
  def self.export
    CSV.open("csv_export/categories.csv", "w") do |csv|
      @categories = Category.all.joins(:episodes).group('categories.id').select('categories.id, categories.slug, count(episodes.id) as count, categories.name').order('count desc')
      @categories.each do |category|
        csv << [category.name, category.count]
      end
    end

  end
  def self.import_categories
    castaways = Castaway.where.not(wikipedia_url: [nil,""])

    castaways.each do |castaway|
      puts "http://en.wikipedia.org#{castaway.wikipedia_url}"
      if castaway.categories != nil
        begin
          html = open("http://en.wikipedia.org#{castaway.wikipedia_url}")
          index_doc = Nokogiri::HTML(html.read)
          index_doc.encoding = 'utf-8'
          category_links = index_doc.css('div#mw-normal-catlinks/ul/li')
          categories = category_links.map { |cl| Category.where(name: cl.inner_text.strip).first_or_create }
          castaway.update(categories: categories)
        rescue
          puts "skipped"
        end
      end
    end
  end
end
