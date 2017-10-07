class RenameTrackColumns < ActiveRecord::Migration[5.1]
  def change
    rename_column :indices, :tracks, :discs
    rename_column :choices, :track_id, :disc_id
    rename_column :discs, :track, :name
  end
end
