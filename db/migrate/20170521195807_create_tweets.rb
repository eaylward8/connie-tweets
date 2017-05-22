class CreateTweets < ActiveRecord::Migration[5.0]
  def change
    create_table :tweets do |t|
      t.string :tw_tweet_id
      t.string :text
      t.datetime :tweet_time
      t.boolean :retweeted
      t.integer :retweet_count
      t.boolean :favorited
      t.integer :favorite_count
      t.boolean :retweet_tf
      t.string :rt_tweet_id
      t.references :tweeter, index: true
      t.timestamps
    end
  end
end
