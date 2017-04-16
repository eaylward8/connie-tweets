class WelcomeController < ApplicationController
  before_action :init_twitter_client

  def index
    @lcc = @client.user('lowcutconnie')
  end
end
