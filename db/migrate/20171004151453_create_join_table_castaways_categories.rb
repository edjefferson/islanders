class CreateJoinTableCastawaysCategories < ActiveRecord::Migration[5.1]
  def change
    create_join_table :castaways, :categories do |t|
      # t.index [:castaway_id, :wiki_occupation_id]
      # t.index [:category_id, :category_id]
    end
  end
end
