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
  task :save_data => [:environment] do |t, args|
    client = TwitterClient.new
    search_terms = ['low cut connie', 'lowcutconnie', '@lowcutconnie']

    summary = search_terms.each_with_object({}) do |term, obj|
      obj[term] = {
        tweets_found: 0,
        since_tweet: nil,
        tweets_created: 0,
        tweeters_created: 0,
        tweeters_updated: 0,
        tweeters_update_skipped: 0
      }
    end

    search_terms.each do |term|
      since_id = Tweet.maximum(:tw_tweet_id)
      search_results = client.search(term.to_s, result_type: 'recent', since_id: since_id)
      summary[term][:tweets_found] = search_results.count
      summary[term][:since_tweet] = since_id

      search_results.each do |tweet|
        user = tweet.user

        if Tweet.find_by(tw_tweet_id: tweet.id.to_s)
          puts "Already have tweet #{tweet.id.to_s}"
          next
        end

        if tweeter = Tweeter.find_by(tw_user_id: user.id.to_s)
          if tweeter.updated_at < 1.day.ago
            update_tweeter(tweeter, user)
            summary[term][:tweeters_updated] += 1
          else
            summary[term][:tweeters_update_skipped] += 1
          end

          create_tweet(tweet, tweeter)
          summary[term][:tweets_created] += 1
        else
          tweeter = create_tweeter(user)
          summary[term][:tweeters_created] += 1
          create_tweet(tweet, tweeter)
          summary[term][:tweets_created] += 1
        end
      end
    end
    handle_summary(summary)
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

  def handle_summary(summary)
    if Rails.env.production?
      SaveTweetsMailer.daily_summary_email(summary).deliver_now
    else
      puts summary.to_yaml
    end
  end
end
