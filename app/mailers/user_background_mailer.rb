require "osprotect/restrict_events_based_on_users_access"
require "osprotect/date_ranges"

class UserBackgroundMailer < ActionMailer::Base
  include Resque::Mailer
  include Osprotect::DateRanges
  include Osprotect::RestrictEventsBasedOnUsersAccess

  default from: APP_CONFIG[:emails_from]

  def password_reset(user_id)
    @user = User.find(user_id)
    mail :to => @user.email, :subject => "Password Reset"
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

  def events_cron_report(user_id, report_id)
    @user = User.find(user_id)
    @report = Report.find(report_id)
    time_range = 'yesterday'  if @report.auto_run_at == 'd'
    time_range = 'last_week'  if @report.auto_run_at == 'w'
    time_range = 'last_month' if @report.auto_run_at == 'm'
    @report.report_criteria[:relative_date_range] = time_range
    # cls: @report.report_criteria[:relative_date_range] = 'past_year'
    get_events_based_on_groups_for_user(@user.id) # sets @events
    @event_search = EventSearch.new(@report.report_criteria)
    @events = @event_search.filter(@events) # sets: @start_time and @end_time
    @report_title = set_report_title(@report.auto_run_at, 'Events Report for', @event_search.start_time, @event_search.end_time)
    events_count = @events.count
    max_exceeded = (events_count > APP_CONFIG[:max_events_per_pdf]) ? true : false
    @events = @events.limit(APP_CONFIG[:max_events_per_pdf])
    if events_count > 0
      pdf_doc = EventsPdf.new(@user, @report, @report_title, max_exceeded, APP_CONFIG[:max_events_per_pdf], events_count, @events)
      # now save pdf to a file and create a Pdf table entry:
      path = "#{Rails.root}/shared/reports/#{@user.id}/#{@report.auto_run_at}"
      FileUtils.mkdir_p(path) # create path if it doesn't exist
      filename = "#{Time.now.utc.strftime("%Y%m%d%H%M%S%N%Z")}_#{set_name(@report.auto_run_at)}_Events_report.pdf"
      path_and_filename = "#{path}/#{filename}"
      pdf_file = pdf_doc.render_file(path_and_filename)
      if pdf_file.is_a? File
        pdf = Pdf.new
        pdf.user_id = @user.id
        pdf.report_id = @report.id
        pdf.pdf_type = 1 # events
        pdf.creation_criteria = @report.report_criteria
        pdf.path_to_file = path
        pdf.file_name = filename
        pdf.save!
      end
      # note: having Prawn render again is slower than just reading the file from disk:
      # attachments[filename] = pdf_doc.render
      attachments[filename] = File.read(path_and_filename)
    end
    mail :to => @user.email, :subject => "osProtect: #{@report_title}"
  end

  def incidents_cron_report(user_id, report_id)
    @user = User.find(user_id)
    @report = Report.find(report_id)
    time_range = 'yesterday'  if @report.auto_run_at == 'd'
    time_range = 'last_week'  if @report.auto_run_at == 'w'
    time_range = 'last_month' if @report.auto_run_at == 'm'
    @report.report_criteria[:relative_date_range] = time_range
    if @user.role? :admin
      @incidents = Incident.joins(:incident_events).order("incidents.created_at DESC")
    else
      @incidents = Incident.where("sid IN (?)", @user.sensors).joins(:incident_events).order("incidents.created_at DESC")
    end
    @incident_event_search = IncidentEventSearch.new(@report.report_criteria)
    @incidents = @incident_event_search.filter(@incidents) # sets: @start_time and @end_time
    @report_title = set_report_title(@report.auto_run_at, 'Incidents Report for', @incident_event_search.start_time, @incident_event_search.end_time)
    @incidents_count = @incidents.count
    max_exceeded = (@incidents_count > APP_CONFIG[:max_incidents_per_pdf]) ? true : false
    @incidents = @incidents.limit(APP_CONFIG[:max_incidents_per_pdf])
    if @incidents_count > 0
      pdf_doc = IncidentsPdf.new(@user, @report, @report_title, max_exceeded, APP_CONFIG[:max_incidents_per_pdf], @incidents_count, @incidents)
      # now save pdf to a file and create a Pdf table entry:
      path = "#{Rails.root}/shared/reports/#{@user.id}/#{@report.auto_run_at}"
      FileUtils.mkdir_p(path) # create path if it doesn't exist
      filename = "#{Time.now.utc.strftime("%Y%m%d%H%M%S%N%Z")}_#{set_name(@report.auto_run_at)}_Incidents_report.pdf"
      path_and_filename = "#{path}/#{filename}"
      pdf_file = pdf_doc.render_file(path_and_filename)
      if pdf_file.is_a? File
        pdf = Pdf.new
        pdf.user_id = @user.id
        pdf.report_id = @report.id
        pdf.pdf_type = 2 # incidents
        pdf.creation_criteria = @report.report_criteria
        pdf.path_to_file = path
        pdf.file_name = filename
        pdf.save!
      end
      # note: having Prawn render again is slower than just reading the file from disk:
      # attachments[filename] = pdf_doc.render
      attachments[filename] = File.read(path_and_filename)
    end
    mail :to => @user.email, :subject => "osProtect: #{@report_title}"
  end

  private

  def set_name(auto_run_at)
    name = ''
    name = 'Daily'   if auto_run_at == 'd'
    name = 'Weekly'  if auto_run_at == 'w'
    name = 'Monthly' if auto_run_at == 'm'
    name
  end

  def set_report_title(auto_run_at, type, start_time, end_time)
    name = set_name(auto_run_at)
    name + ' ' + type + ' ' + start_time.utc.strftime("%a %b %d, %Y %I:%M:%S %P %Z") + ' - ' + end_time.utc.strftime("%a %b %d, %Y %I:%M:%S %P %Z")
  end
end
