class AddBibleToEpisodes < ActiveRecord::Migration[5.1]
  def change
    add_column :episodes, :bible, :string
  end
end
