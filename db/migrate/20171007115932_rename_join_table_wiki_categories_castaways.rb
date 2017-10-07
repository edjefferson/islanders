class RenameJoinTableWikiCategoriesCastaways < ActiveRecord::Migration[5.1]
  def change
    rename_table :castaways_categories, :castaways_wiki_categories
  end
end
