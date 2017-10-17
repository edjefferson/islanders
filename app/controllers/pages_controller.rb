class PagesController < ApplicationController


  def index
    @decades = ["1940s","1950s","1960s","1970s","1980s","1990s","2000s","2010s"]

    @current_decade = params[:decade]
    if @current_decade != nil
      index = Index.where(index_type: "decade", key: @current_decade).first

    else
      index = Index.where(index_type: "decade", key: "").first
    end

    if @current_decade == nil
      @episodes = Episode.all
    else
      start_date = "#{@current_decade[0..-2]}-01-01"
      end_date = "#{@current_decade[0..-2].to_i + 9}-12-31"
      @episodes = Episode.where(:broadcast_date => start_date..end_date)
    end
    @artists = index.artists
    @discs = index.discs
    @books = index.books
    @luxuries = index.luxuries
    puts index.inspect
    @castaways_count = Episode.where.not(broadcast_date: nil).count
    @records_count = Disc.count
    @artists_count = Artist.count
    @start_date = Episode.where.not(broadcast_date: nil).order(broadcast_date: :asc).first.episode_date

=begin
    classical_artists = Artist.joins(:genres).where("genres.name like '%classical%' OR genres.name like '%opera%'").select('artists.id')
    @classical_count = Choice.joins(:disc).where(:episode_id => @episodes.pluck(:id), :discs => {:artist_id => [classical_artists.pluck(:id)]}).count
    @total_count = Choice.where(:episode_id => @episodes.pluck(:id)).count
    @non_classical_count = @total_count - @classical_count
=end
    indexes = {}
    indexes["stats"] = {"castaway_count" => @castaways_count, "artist_count" => @artists_count, "disc_count" => @records_count}

    Index.all.each do |index|
      indexes[index.index_type + "_" + index.key] = {artists: index.artists, discs: index.discs, books: index.books, luxuries: index.luxuries}
    end

    @feed =  OpenStruct.new({data: indexes})

  end

  def artists
    @artists = Artist.all.order(:name).select(:id, :name,:appearances)
    artist_data = {}
    @artists.each do |artist|
      choices = Choice.joins(:artist,:episode).where('artists.id = ?',artist.id)
      puts choices.count
      @all_chart_data = get_decade_data(choices)
      puts artist.name
      puts @all_chart_data
      artist_data[artist.name] = @all_chart_data
    end
    @feed =  OpenStruct.new({data: artist_data})
  end


end
