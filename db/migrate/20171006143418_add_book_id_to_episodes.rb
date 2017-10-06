class AddBookIdToEpisodes < ActiveRecord::Migration[5.1]
  def change
    add_column :episodes, :book_id, :string
    add_index :episodes, :book_id
  end
end
