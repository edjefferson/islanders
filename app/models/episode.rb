require 'open-uri'
require 'csv'


class Episode < ApplicationRecord

  extend FriendlyId
  friendly_id :episode_date, use: :slugged

  belongs_to :castaway
  belongs_to :book, required: false
  belongs_to :luxury, required: false
  has_many :choices
  has_many :discs, through: :choices
  has_many :artists, through: :choices
  has_many :categories, through: :castaway

  def special_episodes
    ["http://www.bbc.co.uk/programmes/p04qw02y","http://www.bbc.co.uk/programmes/p00fwc7f"]
  end

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

  def self.create_episode(episode_html)
    castaway_name = episode_html.css("span[property='name']").inner_text.gsub("BBC Radio 4","")
    episode_url = episode_html.css("div.programme").attr("resource").to_s
    castaway_name.gsub!("BBC Radio 4","")
    castaway = Castaway.where(name: castaway_name.strip).first_or_create
    castaway.update(appearances: castaway.appearances + 1)
    self.where(castaway_id: castaway.id, url: episode_url).first_or_create
  end

  def self.import_page(page_no)
    html = open("http://www.bbc.co.uk/programmes/b006qnmr/episodes/guide?page=#{page_no}")
    index_doc = Nokogiri::HTML(html.read)
    index_doc.encoding = 'utf-8'
    episodes = index_doc.css('div.programmes-page/div/ol.highlight-box-wrapper/li')
    episodes.each { |episode_html| self.create_episode(episode_html) }
    puts "imported #{page_no}"
    page_no += 1
    @episodes_left = 0 if episodes.count < 30
    return page_no
  end


  def self.import_urls
    @episodes_left = 1
    page_no = 1
    page_no = import_page(page_no) while @episodes_left == 1
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

  def get_dates_from_offline_cache
    if special_episodes.include?(self.url) == false
      url_code = self.url.split("/")[-1]
      if Dir.glob("offline_dump/*_#{url_code}.html").empty?
        puts self.inspect
        sleep 5
        html = open(self.url)
        html_doc = Nokogiri::HTML(html.read)
        html_doc.encoding = 'utf-8'
        first_broadcast = Time.parse(html_doc.css('time')[0].attr('datetime').to_s + " 12PM")
      else
        first_broadcast =  Dir.glob("offline_dump/*_#{url_code}.html")[0].split("/")[1].split("_")[0]
      end
      self.update(broadcast_date: first_broadcast)
    end
  end

  def create_offline_episode_cache
    self.get_broadcast_date if self.broadcast_date == nil
    url_code = self.url.split("/")[-1]
    file_name = "offline_dump/#{self.broadcast_date.strftime('%Y-%m-%d')}_#{url_code}.html"
    if File.file?(file_name) == false
      File.open(file_name, 'wb') do |f|
        puts file_name
        f.write open("#{self.url}/segments.inc").read
      end
    end
    self.update(offline_cache: true)
  end


  def get_broadcast_date
    html = open(self.url)
    html_doc = Nokogiri::HTML(html.read)
    html_doc.encoding = 'utf-8'
    broadcasts_html = html_doc.css('time') + html_doc.css('span.broadcast-event__date')
    broadcasts = []
    broadcasts_html.map do |timehtml|
      begin
        broadcasts << Time.parse(timehtml.inner_text)
      rescue
        puts "no time"
      end
    end

    broadcasts = broadcasts.uniq.sort
    first_broadcast = broadcasts[0]
    puts broadcasts

    self.update(broadcast_date: first_broadcast, broadcasts: broadcasts)
    self.get_download_link(html_doc) if self.broadcast_date > Time.now


  end

  def get_download_link(html_doc)
    download_link = html_doc.css("a.buttons__download__link")
    self.update(download_url: download_link.attr('href').to_s) if download_link.count > 0
  end

  def make_offline_data_dump
    self.create_offline_episode_cache if offline_cache == false && special_episodes.include?(self.url) == false
  end

  def import_data(update_all = 0)
    if self.choices.distinct.count != 8 || update_all == 1 || self.choices.pluck(:favourite).include?(true) == false
      if self.offline_cache == true && self.broadcast_date != nil
        puts "available offline"
        self.import_segments
      elsif special_episodes.include?(self.url) == false
        puts "not offline"
        self.get_broadcast_date
        if self.broadcast_date <= Time.now
          self.create_offline_episode_cache
          self.import_segments
        end
      end
    end
  end

  def import_segments
    url_code = self.url.split("/")[-1]
    segments_html = open("offline_dump/#{self.broadcast_date.strftime('%Y-%m-%d')}_#{url_code}.html")
    segments_doc = Nokogiri::HTML(segments_html.read)
    segments_doc.encoding = 'utf-8'
    music_choices = segments_doc.css('ul/li.segments-list__item')
    Choice.import(music_choices, self)
  end

  def self.import_wikipedia_table_row(row)
    columns = row.css('td')
    begin
      date = Time.parse(columns[0].css('span')[1].inner_text).strftime('%Y-%m-%d')
    rescue
      date = Time.parse(columns[0].inner_text).strftime('%Y-%m-%d')
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

    episodes = Episode.where('? = ANY(broadcasts)',date)
    if episodes.count == 1
      episodes.first.update(broadcast_date: date, wikipedia_url: link, book_id: book_id, book_name: book_name, bible: bible, luxury_name: luxury_name, luxury_id: luxury.id)
    elsif episodes.count > 1
      puts "too many episodes"
      puts date
      puts row
      sleep 5
    else
      puts "can't find"
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
        table.css('tr')[1..-1].each { |row| self.import_wikipedia_table_row(row) }
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
        episode.choices.order(order: :asc).includes(:disc,:artist).each do |choice|
          csv << [episode.broadcast_date, choice.order, choice.artist.name, choice.disc.disc, choice.favourite]
        end
      end
    end
  end

  def self.import
    Choice.delete_all
    Artist.delete_all
    Disc.delete_all
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
      episode_broadcast_date, order, artist_name, disc_name, favourite = row
      episode = Episode.where(broadcast_date: episode_broadcast_date).first
      artist = Artist.where(name: artist_name).first_or_create
      disc = Disc.where(artist_id: artist.id, disc: disc_name).first_or_create
      choice = Choice.where(episode_id: episode.id, order: order).first_or_create
      choice.update(disc_id: disc.id, favourite: favourite)
    end

  end
end
