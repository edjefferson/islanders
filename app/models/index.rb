class Index < ApplicationRecord
  def self.generate_decade_indexes
    type = "decade"
    decades = ["","1940s","1950s","1960s","1970s","1980s","1990s","2000s","2010s"]

    decades.each do |decade|
      if decade == ""
        episodes = Episode.all.includes(:tracks,:artists)
      else
        start_date = "#{decade[0..-2]}-01-01"
        end_date = "#{decade[0..-2].to_i + 9}-12-31"
        episodes = Episode.where(:broadcast_date => start_date..end_date).includes(:tracks,:artists)
      end

      artists = {}
      tracks = {}
      books = {}
      luxuries = {}


      episodes.each do |episode|
        episode.tracks.each do |track|
          key = [track.track, track.artist.name, track.slug]
          tracks[key] == nil ? tracks[key] = 1 : tracks[key] += 1
        end
        episode.artists.each do |artist|
          key = [artist.name, artist.slug]
          artists[key] == nil ? artists[key] = 1 : artists[key] += 1
        end
        if episode.book != nil
          books[episode.book] == nil ? books[episode.book] = 1 : books[episode.book] += 1
          luxuries[episode.luxury] == nil ? luxuries[episode.luxury] = 1 : luxuries[episode.luxury] += 1
        end
      end

      top_10_artists = artists.sort_by { |key, count| [- count, key[1] ]}.select { |artist| artist[0][0]!= ""}[0..9]
      top_10_artists.map! { |artist| {name: artist[0][0].to_s, appearances: artist[1], slug: artist[0][1].to_s} }

      top_10_tracks = tracks.sort_by { |key, count| [- count, key[1]] }.select { |track| track[0][0]!= ""}[0..9]
      top_10_tracks.map! { |track| {name: track[0][0].to_s, appearances: track[1], slug: track[0][2].to_s, artist: track[0][1].to_s} }

      top_10_books = books.sort_by { |book, count| [- count, book] }.select { |book| ["No book","Unknown","",nil,"-"].include?(book[0]) == false}[0..9]
      top_10_books.map! { |book| {name: book[0], appearances: book[1] } }

      top_10_luxuries = luxuries.sort_by { |luxury, count| [- count, luxury] }.select { |luxury| ["No item","Unknown","",nil,"-"].include?(luxury[0]) == false}[0..9]
      top_10_luxuries.map! { |luxury| {name: luxury[0], appearances: luxury[1] } }
      index = Index.where(index_type:type, key: decade).first_or_create
      index.update(artists: top_10_artists, tracks: top_10_tracks, books: top_10_books, luxuries: top_10_luxuries)



    end


  end
end
