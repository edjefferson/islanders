class Choice < ApplicationRecord
  belongs_to :episode
  belongs_to :track
  has_one :artist, through: :track

  def self.import(music_choices, episode)
    order = 0
    track_ids = []
    choice_inner_texts = []
    music_choices.each do |music_choice|
      if order < 8
        if music_choice.to_s.upcase.gsub("’","'").include?("CASTAWAY'S FAVOURITE")
          track_is_favourite = true
        else
          track_is_favourite = false
        end

        if music_choice.css("span[property='name']").count > 1
          artist_count = music_choice.css('span.artist').count
          artist_name = music_choice.css('span.artist').map {|artist| artist.inner_text}.join(" & ")
          track_name = music_choice.css("span[property='name']")[artist_count].inner_text.strip
        else
          artist_name = nil
          track_name = music_choice.css("span[property='name']").inner_text.strip
        end
        info = music_choice.css('li.inline')
        album =  music_choice.css('li.inline/em').inner_text.strip
        album = album[0..-2] if album[-1] == "."
        track_number = music_choice.css("abbr[title='Track Number']").inner_text.split(".")[0]
        record_label = music_choice.css("abbr[title='Record Label']").inner_text.strip
        record_label = record_label[0..-2] if record_label[-1] == "."
        performed_by = music_choice.css("span[property='contributor']").to_a.map { |x| x.inner_text.strip }
        if track_name == ""
          track_name = music_choice.inner_text.strip
        end

        artist = Artist.where('lower(name) = ?', artist_name.to_s.downcase).first_or_create(:name=>artist_name)
        #artist.update(appearances: artist.appearances + 1)
        track = Track.where("lower(track) = ? AND artist_id = ?", track_name.to_s.downcase, artist.id).first_or_create(:artist_id => artist.id, :track=>track_name)
        #track.update(appearances: track.appearances + 1)

        choice_inner_text = music_choice.css('div.segment__content').inner_text
        #do something to stop favourites being duplicated
        if track_ids.include?(track.id) == false || choice_inner_texts.include?(choice_inner_text) == false
          choice_inner_texts << choice_inner_text
          track_ids << track.id
          order += 1
          choice = Choice.where(
            episode_id: episode.id,
            order: order
          ).first_or_create
          choice.update(favourite: track_is_favourite, track_id: track.id)

        end

      end
    end
    episode.choices.where('"order" > 8').delete_all
  end
end
