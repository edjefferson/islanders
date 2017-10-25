class CreateEpisodes < ActiveRecord::Migration[5.1]
  def change
    create_table :episodes do |t|
      t.date :broadcast_date
      t.references :castaway
      t.string :luxury
      t.string :book
      t.string :url
      t.string :download_url

      t.timestamps
    end
  end
end
