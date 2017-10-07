class PagesController < ApplicationController


  def index

    @decades = ["1940s","1950s","1960s","1970s","1980s","1990s","2000s","2010s"]

    @current_decade = params[:decade]
    if @current_decade != nil
      index = Index.where(index_type: "decade", key: @current_decade).first

    else
      index = Index.where(index_type: "decade", key: "").first
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
    @feed =  OpenStruct.new({artists: @artists, discs: @discs, books: @books, luxuries: @luxuries})

  end


end
