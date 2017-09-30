require 'open-uri'

class Episode < ApplicationRecord
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
        self.where(castaway_id: castaway.id, url: episode_url).first_or_create
      end
      page_no += 1
      episodes_left = 0 if episodes.count < 30
    end
  end

  def import_data
    html_doc = Nokogiri::HTML(open(self.url))
    first_broadcast = Time.parse(html_doc.css('div.broadcast-event__time')[0].attr('content'))
    self.update(broadcast_date: first_broadcast)
    if first_broadcast > Time.now
      puts "Hasn't been broadcast yet"
    else
      download_link = html_doc.css("a.buttons__download__link")
      self.update(download_url: download_link.attr('href').to_s) if download_link.count > 0

      html = open("#{self.url}/segments.inc")
      doc = Nokogiri::HTML(html.read)
      doc.encoding = 'utf-8'
      favourite = {track: nil, artist: nil}
      favourite_segment = doc.css('li.segments-list__item--group')
      if favourite_segment.count > 0
        if favourite_segment[0].css('h3').inner_text.strip == "CASTAWAY'S FAVOURITE"
          favourite[:track] = favourite_segment.css("span[property='name']")[1].inner_text.strip
          favourite[:artist] = favourite_segment.css('span.artist').inner_text.strip
        end
      end

      music_choices = doc.css('div.segment--music')
      Choice.import(music_choices, favourite, self)
      break if self.choices.count != 8

      non_music_choices = doc.css("div.text--prose")
      book = nil
      luxury = nil
      non_music_choices.each do |nmc|
        if nmc.css('h3').inner_text.strip == "BOOK CHOICE"
          book = nmc.css('p').inner_text
        elsif nmc.css('h3').inner_text.strip == "LUXURY ITEM"
          luxury = nmc.css('p').inner_text
        end
      end

      if luxury == nil
        #luxury = doc.css('div.segments-list__item--group').inner_text.strip

        non_music_choices = doc.css("li.segments-list__item--group")
        #puts non_music_choices
        book = nil
        luxury = nil
        non_music_choices.each do |nmc|

          if nmc.css('h3')[0].inner_text.strip == "Book Choice"
            book = nmc.css('span').inner_text
          elsif nmc.css('h3')[0].inner_text.strip == "Luxury Choice"
            luxury = nmc.css('span').inner_text
          end
        end
      end
      other_choices = {book: book, luxury: luxury}
      puts other_choices
    end
  end
end
