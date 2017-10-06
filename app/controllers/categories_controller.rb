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
    @categories = Category.all.joins(:episodes).where("episodes.id = ANY('{?}')", @episodes.pluck(:id)).group('categories.id').select('categories.id, categories.slug, count(episodes.id) as count, categories.name').order('count desc')

  end


  def show
    @category = Category.friendly.find(params[:id])

    decade = params[:decade]
    if decade == nil
      @episodes = @category.episodes.order(:broadcast_date).includes(:artists,:tracks,:castaway)
    else
      start_date = "#{decade[0..-2]}-01-01"
      end_date = "#{decade[0..-2].to_i + 9}-12-31"
      @episodes = @category.episodes.where(:broadcast_date => start_date..end_date).order(:broadcast_date).includes(:artists,:tracks,:castaway)
    end


    @artists = Artist.where.not(name: "").joins(:choices).where("choices.episode_id = ANY('{?}')", @episodes.pluck(:id)).select('artists.name as name, count(choices.id) as count, artists.slug as slug').order('count desc').group('name, artists.slug')[0..9]
    @tracks = Track.where.not(track: "").joins(:choices).where("choices.episode_id = ANY('{?}')", @episodes.pluck(:id)).select('tracks.track as name, count(choices.id) as count, tracks.slug as slug').order('count desc').group('name, tracks.slug')[0..9]
    books = {}
    luxuries = {}
    @episodes.each do |episode|
      if episode.book != nil
        books[episode.book] == nil ? books[episode.book] = 1 : books[episode.book] += 1
        luxuries[episode.luxury] == nil ? luxuries[episode.luxury] = 1 : luxuries[episode.luxury] += 1
      end
    end

    top_10_books = books.sort_by { |book, count| [- count, book] }.select { |book| ["No book","Unknown","",nil,"-"].include?(book[0]) == false}[0..9]
    @books = top_10_books.map! { |book| {name: book[0], appearances: book[1] } }

    top_10_luxuries = luxuries.sort_by { |luxury, count| [- count, luxury] }.select { |luxury| ["No item","Unknown","",nil,"-"].include?(luxury[0]) == false}[0..9]
    @luxuries = top_10_luxuries.map! { |luxury| {name: luxury[0], appearances: luxury[1] } }
  end

end
