class CreateTweets < ActiveRecord::Migration[5.0]
  def change
    create_table :tweets do |t|
      t.integer :tw_tweet_id
      t.string :text
      t.datetime :tweeted_at
      t.boolean :retweeted
      t.integer :retweet_count
      t.boolean :favorited
      t.integer :favorite_count
      t.references :tweeter
      t.timestamps
    end
  end
end
