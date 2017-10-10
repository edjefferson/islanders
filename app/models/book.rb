require 'csv'
class Book < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  has_many :episodes

  def self.import_corrections
    CSV.foreach("csv_export/book_corrections.csv") do |row|
      book = Book.where(name:row[0]).first
      if book != nil
        corrected_book = Book.where(name:row[1], title:row[2], author:row[3]).first_or_create

        episodes = Episode.where(book_id: book.id)
        episodes.update(book_id: corrected_book.id)
        book.delete if book.episodes.count == 0
      end
    end
  end

end
