class AddSlugToLuxuries < ActiveRecord::Migration[5.1]
  def change
    add_column :luxuries, :slug, :string
    add_index :luxuries, :slug, unique: true
  end
end
