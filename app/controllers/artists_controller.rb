class ArtistsController < ApplicationController
  def index
    page = params[:page].to_i
    page = 1 if page == 0
    offset =  (page * 40) - 40






    decade = params[:decade]

    if decade == nil
      @episodes = Episode.all
    else
      start_date = "#{decade[0..-2]}-01-01"
      end_date = "#{decade[0..-2].to_i + 9}-12-31"
      @episodes = Episode.where(:broadcast_date => start_date..end_date)
    end
    @artists = Artist.where.not(name: ["-",nil,""]).joins(:episodes).where("episodes.id = ANY('{?}')", @episodes.pluck(:id)).group('artists.id').select('artists.id, artists.slug, count(artists.id) as appearances, artists.name').order('appearances desc').limit(40).offset(offset)

    @biggest_artist_appearances = Artist.where.not(name: ["-",nil,""]).joins(:episodes).where("episodes.id = ANY('{?}')", @episodes.pluck(:id)).group('artists.id').select('artists.id, artists.slug, count(artists.id) as appearances, artists.name').order('appearances desc').limit(1).first.appearances
  end

  def show
    page = params[:page].to_i + 1
    @artist = Artist.friendly.find(params[:id])
    @related_artists = @artist.related_artists_list.map { |artist| [Artist.find(artist["id"]),artist["appearances"]]}
    @tracks = @artist.tracks.order(appearances: :desc, track: :asc).limit(20)
    @episodes = @artist.episodes.order(broadcast_date: :desc).distinct.limit(20)

    @max_tracks = @tracks.first.appearances
    choices = Choice.joins(:artist,:episode).where('artists.id = ?',@artist.id)
    @all_chart_data = choices_decade_chart(choices)
    @chart_options = default_chart_options

  end
end
