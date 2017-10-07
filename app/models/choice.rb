class Choice < ApplicationRecord
  belongs_to :episode
  belongs_to :disc
  has_one :artist, through: :disc

  def self.import(music_choices, episode)
    order = 0
    disc_ids = []
    choice_inner_texts = []
    music_choices.each do |music_choice|
      if order < 8
        if music_choice.to_s.upcase.gsub("’","'").include?("CASTAWAY'S FAVOURITE")
          disc_is_favourite = true
        else
          disc_is_favourite = false
        end

        if music_choice.css("span[property='name']").count > 1
          artist_count = music_choice.css('span.artist').count
          artist_name = music_choice.css('span.artist').map {|artist| artist.inner_text}.join(" & ")
          disc_name = music_choice.css("span[property='name']")[artist_count].inner_text.strip
        else
          artist_name = nil
          disc_name = music_choice.css("span[property='name']").inner_text.strip
        end
        info = music_choice.css('li.inline')
        album =  music_choice.css('li.inline/em').inner_text.strip
        album = album[0..-2] if album[-1] == "."
        disc_number = music_choice.css("abbr[title='Disc Number']").inner_text.split(".")[0]
        record_label = music_choice.css("abbr[title='Record Label']").inner_text.strip
        record_label = record_label[0..-2] if record_label[-1] == "."
        performed_by = music_choice.css("span[property='contributor']").to_a.map { |x| x.inner_text.strip }
        if disc_name == ""
          disc_name = music_choice.inner_text.strip
        end

        artist = Artist.where('lower(name) = ?', artist_name.to_s.downcase).first_or_create(:name=>artist_name)
        #artist.update(appearances: artist.appearances + 1)
        disc = Disc.where("lower(disc) = ? AND artist_id = ?", disc_name.to_s.downcase, artist.id).first_or_create(:artist_id => artist.id, :disc=>disc_name)
        #disc.update(appearances: disc.appearances + 1)

        choice_inner_text = music_choice.css('div.segment__content').inner_text
        #do something to stop favourites being duplicated
        if disc_ids.include?(disc.id) == false || choice_inner_texts.include?(choice_inner_text) == false
          choice_inner_texts << choice_inner_text
          disc_ids << disc.id
          order += 1
          choice = Choice.where(
            episode_id: episode.id,
            order: order
          ).first_or_create
          choice.update(favourite: disc_is_favourite, disc_id: disc.id)

        end

      end
    end
    episode.choices.where('"order" > 8').delete_all
  end
end
