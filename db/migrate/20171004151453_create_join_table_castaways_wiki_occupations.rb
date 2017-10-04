class CreateJoinTableCastawaysWikiOccupations < ActiveRecord::Migration[5.1]
  def change
    create_join_table :castaways, :wiki_occupations do |t|
      # t.index [:castaway_id, :wiki_occupation_id]
      # t.index [:wiki_occupation_id, :castaway_id]
    end
  end
end
