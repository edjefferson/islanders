class CreateWikiOccupations < ActiveRecord::Migration[5.1]
  def change
    create_table :wiki_occupations do |t|
      t.string :name

      t.timestamps
    end
  end
end
