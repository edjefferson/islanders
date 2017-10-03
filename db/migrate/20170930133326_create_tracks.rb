class CreateTracks < ActiveRecord::Migration[5.1]
  def change
    create_table :tracks do |t|
      t.string :track
      t.references :artist
      t.string :album
      t.integer :track_number
      t.string :record_label
      t.string :performers, array: true
      t.integer :appearances, default: 0
      t.timestamps
    end
  end
end
