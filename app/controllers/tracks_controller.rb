class TracksController < ApplicationController

  def index
    page = params[:page].to_i
    page = 1 if page == 0
    offset =  (page * 40) - 40
    @tracks = Track.where.not(track: "").order(appearances: :desc, track: :asc).limit(40).offset(offset)
  end

  def show
    page = params[:page].to_i + 1
    @track = Track.friendly.find(params[:id])
    @episodes = @track.episodes.order(broadcast_date: :asc).each_slice(40).to_a[page - 1]
  end
end
