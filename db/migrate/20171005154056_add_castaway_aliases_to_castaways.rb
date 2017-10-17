class AddCastawayAliasesToCastaways < ActiveRecord::Migration[5.1]
  def change
    add_column :castaways, :castaway_aliases, :string, array: true
  end
end
