namespace :twitter do
  desc 'Get LCC tweets'
  task :save_tweets, [:search_term] => [:environment] do |t, args|
    client = Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV['TW_CONSUMER_KEY']
      config.consumer_secret     = ENV['TW_CONSUMER_SECRET']
      config.access_token        = ENV['TW_ACCESS_TOKEN']
      config.access_token_secret = ENV['TW_ACCESS_TOKEN_SECRET']
    end

    search_term = args[:search_term].present? ? args[:search_term] : 'low cut connie'

    client.search(search_term.to_s, result_type: 'recent').each do |t|
      u = t.user

      if tweeter = Tweeter.find_by(tw_user_id: u.id.to_s)
        tweeter.update_attributes(
          name: u.name,
          screen_name: u.screen_name,
          location: u.location,
          description: u.description,
          url: u.url.to_s,
          followers_count: u.followers_count,
          friends_count: u.friends_count
        )
        puts "Updated Tweeter #{tweeter.id}"
      else
        tweeter = Tweeter.create(
          tw_user_id: u.id.to_s,
          name: u.name,
          screen_name: u.screen_name,
          location: u.location,
          description: u.description,
          url: u.url.to_s,
          followers_count: u.followers_count,
          friends_count: u.friends_count
        )
        puts "Created Tweeter #{tweeter.id}"
      end

      unless Tweet.find_by(tw_tweet_id: t.id.to_s)
        tweet = Tweet.create(
          tw_tweet_id: t.id.to_s,
          tweeter_id: tweeter.id,
          text: t.full_text,
          tweet_time: t.created_at,
          retweeted: t.retweeted?,
          retweet_count: t.retweet_count,
          favorited: t.favorited?,
          favorite_count: t.favorite_count,
          retweet_tf: t.retweet?,
          rt_tweet_id: t.retweeted_tweet&.id.to_s
        )
        puts "Created Tweet #{tweet.id}"
      end
    end
  end
end
