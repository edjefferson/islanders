# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20171007120047) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "artists", force: :cascade do |t|
    t.string "name"
    t.integer "appearances", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
    t.hstore "related_artists", array: true
    t.index ["slug"], name: "index_artists_on_slug", unique: true
  end

  create_table "books", force: :cascade do |t|
    t.string "name"
    t.string "title"
    t.string "author"
    t.string "book_wiki"
    t.string "author_wiki"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
    t.index ["slug"], name: "index_books_on_slug", unique: true
  end

  create_table "castaways", force: :cascade do |t|
    t.string "name"
    t.string "wikipedia_url"
    t.integer "appearances", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "castaway_aliases", array: true
  end

  create_table "castaways_wiki_categories", id: false, force: :cascade do |t|
    t.bigint "castaway_id", null: false
    t.bigint "wiki_category_id", null: false
  end

  create_table "choices", force: :cascade do |t|
    t.bigint "episode_id"
    t.bigint "disc_id"
    t.boolean "favourite"
    t.integer "order"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["disc_id"], name: "index_choices_on_disc_id"
    t.index ["episode_id"], name: "index_choices_on_episode_id"
  end

  create_table "discs", force: :cascade do |t|
    t.string "name"
    t.bigint "artist_id"
    t.string "album"
    t.integer "track_number"
    t.string "record_label"
    t.string "performers", array: true
    t.integer "appearances", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
    t.index ["artist_id"], name: "index_discs_on_artist_id"
    t.index ["slug"], name: "index_discs_on_slug", unique: true
  end

  create_table "episodes", force: :cascade do |t|
    t.datetime "broadcast_date"
    t.bigint "castaway_id"
    t.string "url"
    t.string "download_url"
    t.string "luxury_name"
    t.string "book_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
    t.string "bible"
    t.string "wikipedia_url"
    t.bigint "book_id"
    t.bigint "luxury_id"
    t.index ["book_id"], name: "index_episodes_on_book_id"
    t.index ["castaway_id"], name: "index_episodes_on_castaway_id"
    t.index ["luxury_id"], name: "index_episodes_on_luxury_id"
    t.index ["slug"], name: "index_episodes_on_slug", unique: true
  end

  create_table "indices", force: :cascade do |t|
    t.string "index_type"
    t.string "key"
    t.hstore "artists", array: true
    t.hstore "discs", array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.hstore "books", array: true
    t.hstore "luxuries", array: true
  end

  create_table "luxuries", force: :cascade do |t|
    t.string "name"
    t.string "wiki_urls", array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
    t.index ["slug"], name: "index_luxuries_on_slug", unique: true
  end

  create_table "wiki_categories", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
    t.index ["slug"], name: "index_wiki_categories_on_slug", unique: true
  end

  add_foreign_key "choices", "discs"
  add_foreign_key "choices", "episodes"
end
