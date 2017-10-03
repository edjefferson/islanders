class PagesController < ApplicationController
  def index
    @artists = Artist.where.not(name: "").order(appearances: :desc, name: :asc).limit(10)
    @tracks = Track.where.not(track: "").order(appearances: :desc, track: :asc).limit(10)
    @castaways_count = Episode.where.not(broadcast_date: nil).count
    @start_date = Episode.where.not(broadcast_date: nil).last.episode_date
  end
end
