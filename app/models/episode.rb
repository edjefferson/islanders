require 'open-uri'

class Episode < ApplicationRecord

  extend FriendlyId
  friendly_id :episode_date, use: :slugged

  belongs_to :castaway
  has_many :choices
  has_many :tracks, through: :choices
  has_many :artists, through: :choices


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
        castaway_name = episode_html.css("span[property='name']").inner_text
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


  def import_data
    if self.choices.count < 8
      html_doc = Nokogiri::HTML(open(self.url))
      if ["http://www.bbc.co.uk/programmes/p04qw02y"].include?(self.url) == false
        first_broadcast = Time.parse(html_doc.css('time')[0].attr('datetime').to_s + " 12PM")
        if first_broadcast > Time.now
          puts "Hasn't been broadcast yet"
        else
          download_link = html_doc.css("a.buttons__download__link")
          self.update(download_url: download_link.attr('href').to_s) if download_link.count > 0

          html = open("#{self.url}/segments.inc")
          doc = Nokogiri::HTML(html.read)
          doc.encoding = 'utf-8'


          music_choices = doc.css('li.segments-list__item')[0..7]
          if self.choices.count < 99
            Choice.import(music_choices, self)
          end
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
          if columns[2].css('span').count > 1
            book = columns[2].css('span')[1].inner_text.split("[")[0].to_s
          else
            book = columns[2].inner_text.split("[")[0]
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
            luxury = columns[3].css('span')[1].inner_text.split("[")[0].to_s
          else
            luxury = columns[3].inner_text.split("[")[0].to_s
          end
          #if bible !="Bible"

            #puts date - 1

          episode = Episode.where(broadcast_date: date).first
          if episode != nil
          episode.update(broadcast_date: date, wikipedia_url: link, book: book, bible: bible, luxury: luxury)
          end


        end

      end
    end
  end
end
