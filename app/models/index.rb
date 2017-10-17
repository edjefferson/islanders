class Index < ApplicationRecord
  def self.generate_decade_indexes
    decades = ["","1940s","1950s","1960s","1970s","1980s","1990s","2000s","2010s"]
    classical_artists = Artist.joins(:genres).where("genres.name like '%classical%' OR genres.name like '%opera%'").select('artists.id').uniq
      decades.each do |decade|
        if decade == ""
          episodes = Episode.all.includes(:discs,:artists).uniq
        else
          start_date = "#{decade[0..-2]}-01-01"
          end_date = "#{decade[0..-2].to_i + 9}-12-31"
          episodes = Episode.where(:broadcast_date => start_date..end_date).includes(:discs,:artists).uniq
        end

        @books = Book.where.not(name: [nil,"","-","No book"]).joins(:episodes).where("episodes.id = ANY('{?}')", episodes.pluck(:id).uniq).group('books.id').select('books.id, books.slug, count(episodes.id) as appearances, books.name').order('appearances desc').limit(10)
        @luxuries = Luxury.where.not(name: [nil,"","-","No item"]).joins(:episodes).where("episodes.id = ANY('{?}')", episodes.pluck(:id).uniq).group('luxuries.id').select('luxuries.id, luxuries.slug, count(episodes.id) as appearances, luxuries.name').order('appearances desc').limit(10)
        top_10_books = @books.map{|x| x.serializable_hash}
        top_10_luxuries = @luxuries.map{|x| x.serializable_hash}

        ["all","notclassical","classical"].each do |index_type|


        if index_type == "notclassical"
          @artists = Artist.where.not(name: ["-",nil,""]).joins(:episodes).where("episodes.id = ANY('{?}') AND artists.id != ALL('{?}')", episodes.pluck(:id).uniq,classical_artists).group('artists.id').select('artists.id, artists.slug, count(episodes.id) as appearances, artists.name').order('count(episodes.id) desc')
        #  @discs = Disc.where.not(name: [nil,""]).joins(:episodes,:artist).where("episodes.id = ANY('{?}' AND artists.id = ANY('{?}')", episodes.pluck(:id).uniq,@artists.pluck(:id).uniq).group('discs.id').order('count(episodes.id) desc').select('discs.id, discs.slug, count(episodes.id) as appearances, discs.name as name').limit(10)
        elsif index_type == "classical"
          @artists = Artist.where.not(name: ["-",nil,""]).joins(:episodes).where("episodes.id = ANY('{?}') AND artists.id = ANY('{?}')", episodes.pluck(:id).uniq,classical_artists).group('artists.id').select('artists.id, artists.slug, count(episodes.id) as appearances, artists.name').order('count(episodes.id) desc')
          #@discs = Disc.where.not(name: [nil,""]).joins(:episodes,:artist).where("episodes.id = ANY('{?}' AND artists.id = ANY('{?}')", episodes.pluck(:id).uniq,@artists.pluck(:id).uniq).group('discs.id').order('count(episodes.id) desc').select('discs.id, discs.slug, count(episodes.id) as appearances, discs.name as name').limit(10)
        else
          @artists = Artist.where.not(name: ["-",nil,""]).joins(:episodes).where("episodes.id = ANY('{?}')", episodes.pluck(:id)).group('artists.id').select('artists.id, artists.slug, count(episodes.id) as appearances, artists.name').order('count(episodes.id) desc')

        end

        @discs = Disc.where.not(name: [nil,""]).where(:artist_id => @artists.pluck(:id) ).joins(:episodes).where("episodes.id = ANY('{?}')", episodes.pluck(:id) ).group('discs.id').select('discs.id, discs.slug, count(episodes.id) as appearances, discs.name as name').order('count(episodes.id) desc').limit(10)

        top_10_artists = @artists.map{|x| x.serializable_hash}
        top_10_discs = @discs.map{|x| x.serializable_hash}
        top_10_discs.map {|x| x["artist"] = Disc.find(x["id"]).artist.name }



        index = Index.where(index_type:index_type, key: decade).first_or_create
        index.update(artists:   top_10_artists, discs: top_10_discs, books: top_10_books, luxuries: top_10_luxuries)
        puts @artists.inspect

        puts index.inspect

      end
    end


  end
end
