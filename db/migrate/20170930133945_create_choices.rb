class CreateChoices < ActiveRecord::Migration[5.1]
  def change
    create_table :choices do |t|
      t.references :episode, foreign_key: true
      t.references :track, foreign_key: true
      t.boolean :favourite
      t.integer :order

      t.timestamps
    end
  end
end
