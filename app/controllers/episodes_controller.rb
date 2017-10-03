class EpisodesController < ApplicationController
  def show
    page = params[:page].to_i + 1
    @episode = Episode.friendly.find(params[:id])
    @tracks = @episode.tracks
  end
end
