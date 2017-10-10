class CreateJoinTableCastawaysCastegories < ActiveRecord::Migration[5.1]
  def change
    create_join_table :castaways, :categories do |t|
      # t.index [:castaway_id, :category_id]
      # t.index [:category_id, :castaway_id]
    end
  end
end
