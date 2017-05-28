namespace :twitter do
  desc 'Invoke save_data with specific search terms'
  task :invoke_save_data do
    search_terms = ['low cut connie', 'lowcutconnie', '@lowcutconnie']
    search_terms.each do |term|
      Rake::Task["twitter:save_data"].invoke(term)
      Rake::Task["twitter:save_data"].reenable
    end
  end

  desc 'Save LCC twitter data'
  task :save_data, [:search_term] => [:environment] do |t, args|
    client = TwitterClient.new

    search_term = args[:search_term].present? ? args[:search_term] : 'low cut connie'
    since_id = Tweet.maximum(:tw_tweet_id)
    puts "Search term: #{search_term}, Since_id: #{since_id}"

    search_results = client.search(search_term.to_s, result_type: 'recent', since_id: since_id)
    puts "Search results count: #{search_results.count}"

    search_results.each do |tweet|
      user = tweet.user

      if Tweet.find_by(tw_tweet_id: tweet.id.to_s)
        puts "Already have tweet #{tweet.id.to_s}"
        next
      end

      if tweeter = Tweeter.find_by(tw_user_id: user.id.to_s)
        if tweeter.updated_at < 1.day.ago
          update_tweeter(tweeter, user)
          puts "Updated Tweeter #{tweeter.id}"
        else
          puts "Skipping update of Tweeter #{tweeter.id}"
        end

        create_tweet(tweet, tweeter)
        puts "Created Tweet #{tweet.id}"
      else
        tweeter = create_tweeter(user)
        puts "Created Tweeter #{tweeter.id}"
        create_tweet(tweet, tweeter)
        puts "Created Tweet #{tweet.id}"
      end
    end
  end

  def create_tweeter(user)
    Tweeter.create(
      tw_user_id: user.id.to_s,
      name: user.name,
      screen_name: user.screen_name,
      location: user.location,
      description: user.description,
      url: user.url.to_s,
      followers_count: user.followers_count,
      friends_count: user.friends_count
    )
  end

  def update_tweeter(tweeter, user)
    tweeter.update_attributes(
      name: user.name,
      screen_name: user.screen_name,
      location: user.location,
      description: user.description,
      url: user.url.to_s,
      followers_count: user.followers_count,
      friends_count: user.friends_count
    )
  end

  def create_tweet(tweet, tweeter)
    tweeter.tweets.create(
      tw_tweet_id: tweet.id.to_s,
      text: tweet.full_text,
      tweet_time: tweet.created_at,
      retweeted: tweet.retweeted?,
      retweet_count: tweet.retweet_count,
      favorited: tweet.favorited?,
      favorite_count: tweet.favorite_count,
      retweet_tf: tweet.retweet?,
      rt_tweet_id: tweet.retweeted_tweet&.id.to_s
    )
  end
end
