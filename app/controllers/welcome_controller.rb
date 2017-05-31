class WelcomeController < ApplicationController
  before_action :init_twitter_client

  def index
    @tweets = Tweet.all
  end
end
