class AddFullChoiceTextToChoice < ActiveRecord::Migration[5.1]
  def change
    add_column :choices, :full_choice_text, :string
  end
end
