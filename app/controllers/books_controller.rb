class BooksController < ApplicationController
  def index
    decade = params[:decade]

    if decade == nil
      @episodes = Episode.all
    else
      start_date = "#{decade[0..-2]}-01-01"
      end_date = "#{decade[0..-2].to_i + 9}-12-31"
      @episodes = Episode.where(:broadcast_date => start_date..end_date)
    end
    @books = Book.where.not(name: ["-",nil,""]).joins(:episodes).where("episodes.id = ANY('{?}')", @episodes.pluck(:id)).group('books.id').select('books.id, books.slug, count(episodes.id) as count, books.name').order('count desc')
  end

  def show
    @book = Book.friendly.find(params[:id])
    @episodes = @book.episodes
  end
end
