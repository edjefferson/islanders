class ArtistsController < ApplicationController
  def index
    page = params[:page].to_i
    page = 1 if page == 0
    offset =  (page * 40) - 40
    @artists = Artist.where.not(name: "").order(appearances: :desc, name: :asc).limit(40).offset(offset)
  end

  def show
    page = params[:page].to_i + 1
    @artist = Artist.friendly.find(params[:id])
    @tracks = @artist.tracks.order(appearances: :desc, track: :asc).limit(20)
    @episodes = @artist.episodes.order(broadcast_date: :desc).distinct.limit(20)
    @related_artists = @artist.related_artists.map { |x| [Artist.find(x[0]),x[1]]}
  end
end
