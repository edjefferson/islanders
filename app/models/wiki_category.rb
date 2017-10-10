require 'open-uri'
require 'csv'

class WikiCategory < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  has_and_belongs_to_many :castaways
  has_many :episodes, through: :castaways
  has_many :artists, through: :castaways
  has_many :choices, through: :castaways

  def self.export
    CSV.open("csv_export/categories.csv", "w") do |csv|
      @wiki_categories = WikiCategory.all.joins(:episodes).group('wiki_categories.id').select('wiki_categories.id, wiki_categories.slug, count(episodes.id) as count, wiki_categories.name').order('count desc')
      @wiki_categories.each do |wiki_category|
        csv << [wiki_category.name, wiki_category.count]
      end
    end
  end

  def self.import_categories
    castaways = WikiCategory.where.not(wikipedia_url: [nil,""])

    castaways.each do |castaway|
      puts "http://en.wikipedia.org#{castaway.wikipedia_url}"
      if castaway.categories != nil
        begin
          html = open("http://en.wikipedia.org#{castaway.wikipedia_url}")
          index_doc = Nokogiri::HTML(html.read)
          index_doc.encoding = 'utf-8'
          category_links = index_doc.css('div#mw-normal-catlinks/ul/li')
          categories = category_links.map { |cl| WikiCategory.where(name: cl.inner_text.strip).first_or_create }
          castaway.update(categories: categories)
        rescue
          puts "skipped"
        end
      end
    end
  end
end
