class Tweeter < ApplicationRecord
  has_many :tweets
  validates :tw_user_id, uniqueness: true
end
