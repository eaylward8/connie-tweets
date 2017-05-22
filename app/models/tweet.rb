class Tweet < ApplicationRecord
  belongs_to :tweeter
  validates :tw_tweet_id, uniqueness: true
end
