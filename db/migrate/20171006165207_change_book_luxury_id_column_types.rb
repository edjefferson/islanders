class ChangeBookLuxuryIdColumnTypes < ActiveRecord::Migration[5.1]
  def change
    remove_column :episodes, :book_id
    remove_column :episodes, :luxury_id

    add_column :episodes, :book_id, :bigint
    add_column :episodes, :luxury_id, :bigint

    add_index :episodes, :book_id
    add_index :episodes, :luxury_id
  end
end
