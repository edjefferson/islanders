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
    @tracks = index.tracks

    @books = index.books
    @luxuries = index.luxuries

    @castaways_count = Episode.where.not(broadcast_date: nil).count
    @records_count = Track.count
    @artists_count = Artist.count
    @start_date = Episode.where.not(broadcast_date: nil).order(broadcast_date: :asc).first.episode_date
    @feed =  OpenStruct.new({artists: @artists, tracks: @tracks, books: @books, luxuries: @luxuries})

  end


end
