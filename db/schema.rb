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

ActiveRecord::Schema.define(version: 20170521195807) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "tweeters", force: :cascade do |t|
    t.integer  "tw_user_id"
    t.string   "name"
    t.string   "screen_name"
    t.string   "location"
    t.string   "description"
    t.string   "url"
    t.integer  "followers_count"
    t.integer  "friends_count"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "tweets", force: :cascade do |t|
    t.integer  "tw_tweet_id"
    t.string   "text"
    t.datetime "tweeted_at"
    t.boolean  "retweeted"
    t.integer  "retweet_count"
    t.boolean  "favorited"
    t.integer  "favorite_count"
    t.integer  "tweeter_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.index ["tweeter_id"], name: "index_tweets_on_tweeter_id", using: :btree
  end

end
