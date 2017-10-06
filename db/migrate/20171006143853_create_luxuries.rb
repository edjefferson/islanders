class CreateLuxuries < ActiveRecord::Migration[5.1]
  def change
    create_table :luxuries do |t|
      t.string :name
      t.string :wiki_urls, array: true

      t.timestamps
    end
  end
end
