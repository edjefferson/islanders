require 'open-uri'
require 'csv'

class Episode < ApplicationRecord

  extend FriendlyId
  friendly_id :episode_date, use: :slugged

  belongs_to :castaway
  belongs_to :book
  belongs_to :luxury
  has_many :choices
  has_many :tracks, through: :choices
  has_many :artists, through: :choices
  has_many :categories, through: :castaway

  def episode_date
    if broadcast_date != nil
      return self.broadcast_date.strftime('%Y-%m-%d')
    else
      return self.id
    end
  end

  def self.find_joint_appearances
    joint_episodes = Castaway.where("name like '% and %' or name like '% & %' or name like '% Ascension Islands%'").map(&:episodes).flatten
  end


  def self.import_urls
    episodes_left = 1
    page_no = 1
    while episodes_left == 1
      html = open("http://www.bbc.co.uk/programmes/b006qnmr/episodes/guide?page=#{page_no}")
      index_doc = Nokogiri::HTML(html.read)
      index_doc.encoding = 'utf-8'

      episodes = index_doc.css('div.programmes-page/div/ol.highlight-box-wrapper/li')
      episodes.each do |episode_html|
        castaway_name = episode_html.css("span[property='name']").inner_text.gsub("BBC Radio 4","")
        episode_url = episode_html.css("div.programme").attr("resource").to_s
        castaway = Castaway.where(name: castaway_name).first_or_create
        castaway.update(appearances: castaway.appearances + 1)
        self.where(castaway_id: castaway.id, url: episode_url).first_or_create
      end
      puts "imported #{page_no}"
      page_no += 1
      episodes_left = 0 if episodes.count < 30
    end
  end

  def reset_castaway
    html = open(self.url)
    html_doc = Nokogiri::HTML(html.read)
    html_doc.encoding = 'utf-8'
    castaway_name = html_doc.css('h1').inner_text.strip
    castaway = Castaway.where(name: castaway_name).first_or_create
    castaway.update(appearances: castaway.appearances + 1)
    self.update(castaway_id: castaway.id)
  end

  def import_data(update_all = 0)
    if self.choices.distinct.count != 8 || update_all == 1 || self.choices.pluck(:favourite).include?(true) == false


      html = open(self.url)
      html_doc = Nokogiri::HTML(html.read)
      html_doc.encoding = 'utf-8'
      if ["http://www.bbc.co.uk/programmes/p04qw02y","http://www.bbc.co.uk/programmes/p00fwc7f"].include?(self.url) == false
        first_broadcast = Time.parse(html_doc.css('time')[0].attr('datetime').to_s + " 12PM")
        if first_broadcast > Time.now
          puts "Hasn't been broadcast yet"
        else
          download_link = html_doc.css("a.buttons__download__link")
          self.update(download_url: download_link.attr('href').to_s) if download_link.count > 0

          html = open("#{self.url}/segments.inc")
          doc = Nokogiri::HTML(html.read)
          doc.encoding = 'utf-8'


          music_choices = doc.css('ul/li.segments-list__item')

          Choice.import(music_choices, self)

        end
        self.update(broadcast_date: first_broadcast)
      end
    end
  end

  def self.import_wikipedia_data
    pages = ["1942-46","1951-1960","1961-1970","1971-1980","1981-1990","1991-2000","2001-2010","2011-present"]
    pages.each do |page|
      puts "https://en.wikipedia.org/wiki/List_of_Desert_Island_Discs_episodes_(#{page})"
      html = open("https://en.wikipedia.org/wiki/List_of_Desert_Island_Discs_episodes_(#{page})")
      index_doc = Nokogiri::HTML(html.read)
      index_doc.encoding = 'utf-8'
      tables = index_doc.css('table.wikitable')
      tables.each do |table|

        table.css('tr')[1..-1].each do |row|

          columns = row.css('td')
          begin
            date = Time.parse(columns[0].css('span')[1].inner_text + " 12PM")
          rescue
            date = Time.parse(columns[0].inner_text + " 12PM")
          end
          begin
            name = columns[1].css('span')[1].inner_text
          rescue
            name = columns[1].inner_text
          end
          begin
            link = columns[1].css('a').attr('href').to_s
          rescue
            link = ""
          end

          book_column = columns[2]
          if book_column.inner_text.strip != "No book"
            if book_column.css('span').count > 1
              book_name = book_column.css('span')[1].inner_text.split("[")[0].to_s
            else
              book_name = book_column.inner_text.split("[")[0]
            end

            book = Book.where(name: book_name).first_or_create
            book_id = book.id


            if book_column.css('i').count == 1
              book_title = book_column.css('i').inner_text.split("[")[0].strip
              book_column.css('i/a').count > 0 ? book_wiki = book_column.css('i/a').attr('href') : book_wiki = nil

              book_column.search('i').remove

              remaining_text = book_column.inner_text
              if remaining_text[0..3] == " by "
                book_author = remaining_text[4..-1].split("[")[0].strip
                book_column.css('a').count > 0 ? author_wiki = book_column.css('a').attr('href') : author_wiki = nil
              else

                book_author = nil
                author_wiki = nil
              end
            end
            #puts book_title, book_wiki, book_author, author_wiki

            book.update(title: book_title, book_wiki: book_wiki, author: book_author, author_wiki: author_wiki)
          else
            book_id = nil
          end

          if columns[2].to_s.include?"endnote_bible-kor"
            bible = "Koran"
          elsif columns[2].to_s.include?"endnote_bible-no"
            bible = "No Bible"
          elsif columns[2].to_s.include?"endnote_bible-tor"
            bible = "Torah"
          else
            bible = "Bible"
          end


          if columns[3].css('span').count > 1
            luxury_name = columns[3].css('span')[1].inner_text.split("[")[0].to_s
          else
            luxury_name = columns[3].inner_text.split("[")[0].to_s
          end

          luxury_urls = columns[3].css('a').map { |a| a.attr('href').to_s}

          luxury = Luxury.where(name: luxury_name).first_or_create
          if luxury_urls != []
            luxury.update(wiki_urls: luxury_urls)
          end
          #if bible !="Bible"

            #puts date - 1

          episode = Episode.where(broadcast_date: date).first
          if episode != nil
            episode.update(broadcast_date: date, wikipedia_url: link, book_id: book_id, book_name: book_name, bible: bible, luxury_name: luxury_name, luxury_id: luxury.id)
          end


        end

      end
    end
  end

  def self.export
    CSV.open("csv_export/episodes.csv", "w") do |csv|
      self.order(broadcast_date: :asc).includes(:castaway).each do |episode|
        begin
          castaway_name = episode.castaway.name
        rescue
          castaway_name = nil
        end
        csv << [episode.broadcast_date, castaway_name, episode.url, episode.download_url, episode.wikipedia_url, episode.book, episode.luxury, episode.bible]
      end
    end

    CSV.open("csv_export/choices.csv", "w") do |csv|
      self.order(broadcast_date: :asc).includes(:choices).each do |episode|
        episode.choices.order(order: :asc).includes(:track,:artist).each do |choice|
          csv << [episode.broadcast_date, choice.order, choice.artist.name, choice.track.track, choice.favourite]
        end
      end
    end
  end

  def self.import
    Choice.delete_all
    Artist.delete_all
    Track.delete_all
    Episode.delete_all
    Castaway.delete_all
    CSV.foreach("csv_export/episodes.csv") do |row|
      broadcast_date, castaway_name, url, download_url, wikipedia_url, book, luxury, bible = row
      castaway = Castaway.where(name: castaway_name).first_or_create
      castaway.update(wikipedia_url: wikipedia_url) if [nil,""].include? wikipedia_url == false
      episode = Episode.where(broadcast_date: broadcast_date).first_or_create
      episode.update(castaway_id: castaway.id, url: url, download_url: download_url, wikipedia_url: wikipedia_url, book: book, luxury: luxury, bible: bible)
    end

    CSV.foreach("csv_export/choices.csv") do |row|
      episode_broadcast_date, order, artist_name, track_name, favourite = row
      episode = Episode.where(broadcast_date: episode_broadcast_date).first
      artist = Artist.where(name: artist_name).first_or_create
      track = Track.where(artist_id: artist.id, track: track_name).first_or_create
      choice = Choice.where(episode_id: episode.id, order: order).first_or_create
      choice.update(track_id: track.id, favourite: favourite)
    end

  end
end
