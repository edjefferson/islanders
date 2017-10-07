class RenameJoinTableColumn < ActiveRecord::Migration[5.1]
  def change
    rename_column :castaways_wiki_categories, :category_id, :wiki_category_id
  end
end
