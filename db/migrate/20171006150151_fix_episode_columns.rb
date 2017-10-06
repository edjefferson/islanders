class FixEpisodeColumns < ActiveRecord::Migration[5.1]
  def change
    rename_column :episodes, :luxury, :luxury_name
    rename_column :episodes, :book, :book_name
  end
end
