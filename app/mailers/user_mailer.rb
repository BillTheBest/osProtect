class UserMailer < ActionMailer::Base
  include Resque::Mailer

  if Rails.env.production?
    default from: "osProtect@appsudo.com"
  else
    default from: "from@localhost"
  end

  def password_reset(user_id)
    @user = User.find(user_id)
    # note: subject can be set in your I18n file at config/locales/en.yml with the following lookup:
    #   en.user_mailer.password_reset.subject
    mail :to => @user.email, :subject => "Password Reset"
  end

  def event_notify(user_id, notification_id)
    @user = User.find(user_id)
    @notification = Notification.find(notification_id)
    send_to = @notification.email.blank? ? @user.email : @notification.email
    mail :to => send_to, :subject => "osProtect: Event Notifications"
  end
end
