class RenameModels < ActiveRecord::Migration[5.1]
  def change
    rename_table :tracks, :discs
    rename_table :categories, :wiki_categories
  end
end
