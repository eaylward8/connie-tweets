class SaveTweetsMailer < ApplicationMailer
  default from: 'notifications@connie-tweets.com'

  def daily_summary(summary)
    @summary = summary
    @time = DateTime.now.strftime('%b %e, %Y %I:%M%P')
    mail to: ENV['ADMIN_EMAIL'], subject: "LCC Tweets #{@time}"
  end
end
