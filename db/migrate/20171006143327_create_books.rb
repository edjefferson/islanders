class CreateBooks < ActiveRecord::Migration[5.1]
  def change
    create_table :books do |t|
      t.string :name
      t.string :title
      t.string :author
      t.string :book_wiki
      t.string :author_wiki

      t.timestamps
    end
  end
end
