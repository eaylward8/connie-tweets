class TwitterClient < Twitter::REST::Client
  def initialize
    self.consumer_key        = ENV['TW_CONSUMER_KEY']
    self.consumer_secret     = ENV['TW_CONSUMER_SECRET']
    self.access_token        = ENV['TW_ACCESS_TOKEN']
    self.access_token_secret = ENV['TW_ACCESS_TOKEN_SECRET']
  end
end
