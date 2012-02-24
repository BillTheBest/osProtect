require "osprotect/date_ranges"

class UserBackgroundMailer < ActionMailer::Base
  include Resque::Mailer
  include Osprotect::DateRanges

  default from: APP_CONFIG[:emails_from]

  def password_reset(user_id)
    @user = User.find(user_id)
    # note: subject can be set in your I18n file at config/locales/en.yml with the following lookup:
    #   en.user_mailer.password_reset.subject
    mail :to => @user.email, :subject => "Password Reset"
  end

  def cron_report(user_id, report_id, pdf_max_records, daily_weekly_monthly)
    @user = User.find(user_id)
    @report = Report.find(report_id)
    time_range = 'yesterday'  if daily_weekly_monthly == 1
    time_range = 'last_week'  if daily_weekly_monthly == 2
    time_range = 'last_month' if daily_weekly_monthly == 3
    @report.report_criteria[:relative_date_range] = time_range
    @report_type = @report.auto_run_at_to_s
    event = Event.new
    @events = event.get_events_based_on_groups_for_user(@user.id)
    @event_search = EventSearch.new(@report.report_criteria)
    @events = @event_search.filter(@events)
    @events = @events.limit(pdf_max_records)
    if @events.count > 0
      pdf = EventsPdf.new(@user, @report, @events)
      attachments["#{Time.now.utc.strftime("%Y%m%d%H%M%S%N%Z")}_daily_report.pdf"] = pdf.render
      path = "#{Rails.root}/shared/reports"
      filename = "#{Time.now.utc.strftime("%Y%m%d%H%M%S%N%Z")}_daily_report.pdf"
      pdf_file = pdf.render_file("#{path}/#{filename}")
    end
    mail :to => @user.email, :subject => "osProtect: #{@report_type} Report: #{@report.name} (##{@report.id})"
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

  # used to test notifications:
  # def event_notify(notification_id, notification_result_id)
  #   @notification_result = NotificationResult.find(notification_result_id)
  #   @notification = Notification.find(notification_id)
  #   @user = User.find(@notification.user_id)
  #   send_to = @notification.email.blank? ? @user.email : @notification.email
  #   @notification_result.email_sent = true
  #   @notification_result.save!
  #   mail :to => send_to, :subject => "osProtect: Event Notification Results"
  # end
end
