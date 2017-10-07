class DiscsController < ApplicationController

  def index
    page = params[:page].to_i
    page = 1 if page == 0
    offset =  (page * 40) - 40
    @discs = Disc.where.not(name: "").order(appearances: :desc, name: :asc).limit(40).offset(offset)
  end

  def show
    page = params[:page].to_i + 1
    @disc = Disc.friendly.find(params[:id])
    @episodes = @disc.episodes.distinct.order(broadcast_date: :asc).each_slice(40).to_a[page - 1]

    choices = Choice.joins(:disc,:episode).where('discs.id = ?',@disc.id)
    @chart_options = default_chart_options
    @all_chart_data = choices_decade_chart(choices)

  end
end
