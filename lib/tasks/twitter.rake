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
    client = Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV['TW_CONSUMER_KEY']
      config.consumer_secret     = ENV['TW_CONSUMER_SECRET']
      config.access_token        = ENV['TW_ACCESS_TOKEN']
      config.access_token_secret = ENV['TW_ACCESS_TOKEN_SECRET']
    end

    search_term = args[:search_term].present? ? args[:search_term] : 'low cut connie'
    since_id = Tweet.maximum(:tw_tweet_id)
    puts "Search term: #{search_term}, Since_id: #{since_id}"

    search_results = client.search(search_term.to_s, result_type: 'recent', since_id: since_id)
    puts "Search results count: #{search_results.count}"

    search_results.each do |t|
      u = t.user

      if Tweet.find_by(tw_tweet_id: t.id.to_s)
        puts "Already have tweet #{t.id.to_s}"
        next
      end

      if tweeter = Tweeter.find_by(tw_user_id: u.id.to_s)
        unless tweeter.updated_at > 1.day.ago
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
        end

        puts "Skipping update of Tweeter #{tweeter.id}"
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
