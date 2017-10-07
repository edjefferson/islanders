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
      @artists = Artist.where.not(name: [nil,""]).joins(:episodes).where("episodes.id = ANY('{?}')", episodes.pluck(:id)).group('artists.id').select('artists.id, artists.slug, count(episodes.id) as appearances, artists.name').order('appearances desc').limit(10)

      @tracks = Track.where.not(track: [nil,""]).joins(:episodes).where("episodes.id = ANY('{?}')", episodes.pluck(:id)).group('tracks.id').select('tracks.id, tracks.slug, count(episodes.id) as appearances, tracks.track as name').order('appearances desc').limit(10)
      @books = Book.where.not(name: [nil,"","-","No book"]).joins(:episodes).where("episodes.id = ANY('{?}')", episodes.pluck(:id)).group('books.id').select('books.id, books.slug, count(episodes.id) as appearances, books.name').order('appearances desc').limit(10)
      @luxuries = Luxury.where.not(name: [nil,"","-","No item"]).joins(:episodes).where("episodes.id = ANY('{?}')", episodes.pluck(:id)).group('luxuries.id').select('luxuries.id, luxuries.slug, count(episodes.id) as appearances, luxuries.name').order('appearances desc').limit(10)

      top_10_artists = @artists.map{|x| x.serializable_hash}
      top_10_tracks = @tracks.map{|x| x.serializable_hash}
      top_10_tracks.map {|x| x["artist"] = Track.find(x["id"]).artist.name }

      top_10_books = @books.map{|x| x.serializable_hash}
      top_10_luxuries = @luxuries.map{|x| x.serializable_hash}

      index = Index.where(index_type:type, key: decade).first_or_create
      index.update(artists:   top_10_artists, tracks: top_10_tracks, books: top_10_books, luxuries: top_10_luxuries)
      puts @artists.inspect

      puts index.inspect
      sleep 1
    end


  end
end
