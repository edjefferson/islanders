class Choice < ApplicationRecord
  belongs_to :episode
  belongs_to :track

  def self.import(music_choices, favourite, episode)
    puts music_choices.count
    order = 0
    music_choices.each do |music_choice|
      order += 1
      track_is_favourite = false
      if music_choice.css("span[property='name']").count > 1
        track_name = music_choice.css("span[property='name']")[1].inner_text.strip
        artist_name = music_choice.css('span.artist').inner_text.strip
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

      if track_name == favourite[:track] && artist_name == favourite[:artist]
        track_is_favourite = true
      end
      artist = Artist.where(name: artist_name).first_or_create
      track = Track.where(
        track: track_name,
        artist_id: artist.id,
        album: album,
        track_number: track_number,
        record_label: record_label,
        performed_by: performed_by
      ).first_or_create
      choice = Choice.where(
        episode_id: episode.id,
        track_id: track.id,
        favourite: track_is_favourite,
        order: order
      ).first_or_create
      puts artist.inspect, track.inspect, choice.inspect
    end
  end
end
