class CreateCastaways < ActiveRecord::Migration[5.1]
  def change
    create_table :castaways do |t|
      t.string :name
      t.string :wikipedia_url
      t.integer :appearances, default: 0

      t.timestamps
    end
  end
end
