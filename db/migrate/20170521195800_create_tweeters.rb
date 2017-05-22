class CreateTweeters < ActiveRecord::Migration[5.0]
  def change
    create_table :tweeters do |t|
      t.string :tw_user_id
      t.string :name
      t.string :screen_name
      t.string :location
      t.string :description
      t.string :url
      t.integer :followers_count
      t.integer :friends_count
      t.timestamps
    end
  end
end
