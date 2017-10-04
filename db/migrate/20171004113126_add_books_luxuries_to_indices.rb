class AddBooksLuxuriesToIndices < ActiveRecord::Migration[5.1]
  def change
    add_column :indices, :books, :hstore, array: true
    add_column :indices, :luxuries, :hstore, array: true
  end
end
