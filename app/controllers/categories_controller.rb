class CategoriesController < ApplicationController
  def index
    decade = params[:decade]

    if decade == nil
      @episodes = Episode.all
    else
      start_date = "#{decade[0..-2]}-01-01"
      end_date = "#{decade[0..-2].to_i + 9}-12-31"
      @episodes = Episode.where(:broadcast_date => start_date..end_date)
    end
    @categories = Category.all.joins(:episodes).where("episodes.id = ANY('{?}')", @episodes.pluck(:id)).group('categories.id').select('categories.id, categories.slug, count(episodes.id) as count, categories.name').order('count desc').limit(40)

  end


  def show
    @category = Category.friendly.find(params[:id])

    decade = params[:decade]
    if decade == nil
      @episodes = @category.episodes.order(:broadcast_date).includes(:artists,:discs,:castaway)
    else
      start_date = "#{decade[0..-2]}-01-01"
      end_date = "#{decade[0..-2].to_i + 9}-12-31"
      @episodes = @category.episodes.where(:broadcast_date => start_date..end_date).order(:broadcast_date).includes(:artists,:discs,:castaway)
    end


    @artists = Artist.where.not(name: "").joins(:choices).where("choices.episode_id = ANY('{?}')", @episodes.pluck(:id)).select('artists.name as name, count(choices.id) as count, artists.slug as slug').order('count desc').group('artists.name, artists.slug')[0..9]
    @discs = Disc.where.not(name: "").joins(:choices).where("choices.episode_id = ANY('{?}')", @episodes.pluck(:id)).select('discs.name as name, count(choices.id) as count, discs.slug as slug').order('count desc').group('discs.name, discs.slug')[0..9]
    @books = Book.where.not(name: "").joins(:episodes).where("episodes.id = ANY('{?}')", @episodes.pluck(:id)).select('books.name as name, count(episodes.id) as count, books.slug as slug').order('count desc').group('name, books.slug')[0..9]
    @luxuries = Luxury.where.not(name: "").joins(:episodes).where("episodes.id = ANY('{?}')", @episodes.pluck(:id)).select('luxuries.name as name, count(episodes.id) as count, luxuries.slug as slug').order('count desc').group('name, luxuries.slug')[0..9]
  end

end
