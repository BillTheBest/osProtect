class UserMailer < ActionMailer::Base
  include Resque::Mailer

  if Rails.env.production?
    default from: "do.not.reply.osProtect@appsudo.com"
  else
    default from: "do.not.reply@localhost"
  end

  def password_reset(user_id)
    @user = User.find(user_id)
    # note: subject can be set in your I18n file at config/locales/en.yml with the following lookup:
    #   en.user_mailer.password_reset.subject
    mail :to => @user.email, :subject => "Password Reset"
  end

  def event_notify(notification_id, notification_result_id)
    @notification_result = NotificationResult.find(notification_result_id)
    @notification = Notification.find(notification_id)
    @user = User.find(@notification.user_id)
    send_to = @notification.email.blank? ? @user.email : @notification.email
    @notification_result.email_sent = true
    @notification_result.save!
    mail :to => send_to, :subject => "osProtect: Event Notification Results"
  end

  def batched_email_notifications(notification_id)
    @notification = Notification.find(notification_id)
    @user = User.find(@notification.user_id)
    send_to = @notification.email.blank? ? @user.email : @notification.email
    @notification_results = @notification.notification_results.where(email_sent: false).order('created_at ASC')
    return if @notification_results.count < 1
    mail :to => send_to, :subject => "osProtect: Event Notification Results"
    @notification_results.update_all(email_sent: true)
  end
end
