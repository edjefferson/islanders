class LuxuriesController < ApplicationController
  def index
    decade = params[:decade]

    if decade == nil
      @episodes = Episode.all
    else
      start_date = "#{decade[0..-2]}-01-01"
      end_date = "#{decade[0..-2].to_i + 9}-12-31"
      @episodes = Episode.where(:broadcast_date => start_date..end_date)
    end
    @luxuries = Luxury.where.not(name: ["-",nil,""]).joins(:episodes).where("episodes.id = ANY('{?}')", @episodes.pluck(:id)).group('luxuries.id').select('luxuries.id, luxuries.slug, count(episodes.id) as count, luxuries.name').order('count desc')
  end

  def show
    @luxury = Luxury.friendly.find(params[:id])
    @episodes = @luxury.episodes
  end
end
