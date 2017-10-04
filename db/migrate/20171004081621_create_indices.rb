class CreateIndices < ActiveRecord::Migration[5.1]
  def change
    enable_extension 'hstore' unless extension_enabled?('hstore')
    create_table :indices do |t|
      t.string :index_type
      t.string :key
      t.hstore :artists, array: true
      t.hstore :tracks, array: true

      t.timestamps
    end
  end
end
