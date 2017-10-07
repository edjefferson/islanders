class AddOwnRecordToChoices < ActiveRecord::Migration[5.1]
  def change
    add_column :choices, :own_record, :boolean, default: false
  end
end
