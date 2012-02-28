require "osprotect/restrict_events_based_on_users_access"
require "osprotect/date_ranges"

class UserBackgroundMailer < ActionMailer::Base
  include Resque::Mailer
  include Osprotect::DateRanges
  include Osprotect::RestrictEventsBasedOnUsersAccess

  default from: APP_CONFIG[:emails_from]

  def password_reset(user_id)
    @user = User.find(user_id)
    # note: subject can be set in your I18n file at config/locales/en.yml with the following lookup:
    #   en.user_mailer.password_reset.subject
    mail :to => @user.email, :subject => "Password Reset"
  end

  def cron_report(user_id, report_id, max_events_per_pdf, daily_weekly_monthly)
    @user = User.find(user_id)
    @report = Report.find(report_id)
    time_range = 'yesterday'  if daily_weekly_monthly == 1
    time_range = 'last_week'  if daily_weekly_monthly == 2
    time_range = 'last_month' if daily_weekly_monthly == 3
    @report.report_criteria[:relative_date_range] = time_range
    # cls: @report.report_criteria[:relative_date_range] = 'past_year'
    @report_type = @report.auto_run_at_to_s
    get_events_based_on_groups_for_user(@user.id) # sets @events
    @event_search = EventSearch.new(@report.report_criteria)
    @events = @event_search.filter(@events) # sets: @start_time and @end_time
    report_title = set_report_title(daily_weekly_monthly, 'Events Report for', @event_search.start_time, @event_search.end_time)
    events_count = @events.count
    max_exceeded = (events_count > max_events_per_pdf) ? true : false
    @events = @events.limit(max_events_per_pdf)
    if events_count > 0
      pdf = EventsPdf.new(@user, @report, report_title, max_exceeded, max_events_per_pdf, events_count, @events)
      attachments["#{Time.now.utc.strftime("%Y%m%d%H%M%S%N%Z")}_daily_report.pdf"] = pdf.render
      path = "#{Rails.root}/shared/reports"
      filename = "#{Time.now.utc.strftime("%Y%m%d%H%M%S%N%Z")}_daily_report.pdf"
      pdf_file = pdf.render_file("#{path}/#{filename}")
    end
    mail :to => @user.email, :subject => "osProtect: #{report_title}"
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

  private

  def set_report_title(dwm, type, start_time, end_time)
    name = ''
    name = 'Daily'   if dwm == 1
    name = 'Weekly'  if dwm == 2
    name = 'Monthly' if dwm == 3
    name + ' ' + type + ' ' + start_time.utc.strftime("%a %b %d, %Y %I:%M:%S %P %Z") + ' - ' + end_time.utc.strftime("%a %b %d, %Y %I:%M:%S %P %Z")
  end
end
