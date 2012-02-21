# note: we are doing explicit require's and include's so it is clear as to what is going on, and
#       just in case some brave soul will try to run this app in thread safe mode
require "osprotect/restrict_events_based_on_users_access"
require "osprotect/date_ranges"

class ReportsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :ensure_user_is_setup

  include Osprotect::RestrictEventsBasedOnUsersAccess
  include Osprotect::DateRanges

  respond_to :html
  respond_to :pdf, only: [:create_pdf]

  def events_listing
    # only allow reports for the current_user or reports that an admin created for all users:
    @report = Report.where('(for_all_users = ? OR user_id = ?) AND id = ?', true, current_user.id, params[:id]).first
    redirect_to reports_url if @report.blank?
    get_events_based_on_groups_for_user(current_user.id) # sets @events
    filter_events_based_on(params[:q]) # sets @event_search
    @events = @events.page(params[:page]).per_page(12)
    pulse
  end

  def index
    # list reports for current_user, or current_user.groups, or admin created for all users:
    @reports = Report.where('for_all_users = ? OR user_id = ?', true, current_user.id).order("updated_at desc").page(params[:page]).per_page(12)
  end

  def show
    redirect_to reports_url
  end

  def new
    @report = Report.new
    @event_search = EventSearch.new(nil)
  end

  def create
    # FIXME report accessible by: 
    #       admins: 'only me', 'any group', 'group 1', 'group 2', ... selecting all groups='any group'
    #       users:  'only me', 'current_user's group(s)', ...
    #       - report_groups ... a model/table to link a report to group(s)
    @report = Report.new(params[:report])
    @report.user_id = current_user.id
    # @report.report_type = 1 # default is 1=EventsReport
    @report.for_all_users = true if current_user.role? :admin
    @report.report_criteria = params[:q]
    if @report.save
      redirect_to @report, notice: 'Report was successfully created.'
    else
      @event_search = EventSearch.new(params[:q])
      render action: "new"
    end
  end

  def edit
    @report = current_user.reports.find(params[:id])
    @event_search = EventSearch.new(@report.report_criteria)
  end

  def update
    @report = current_user.reports.find(params[:id])
    @report.report_criteria = params[:q]
    if @report.update_attributes(params[:report])
      redirect_to @report, notice: 'Report was successfully updated.'
    else
      @event_search = EventSearch.new(params[:q])
      render action: "edit"
    end
  end

  def destroy
    @report = current_user.reports.find(params[:id])
    @report.pdfs.each do |pdf|
      file = pdf.path_to_file + '/' + pdf.file_name
      begin
        FileUtils.rm(file) if File.exist?(file)
      rescue Errno::ENOENT => e
        # ignore file-not-found, let everything else pass
      end
    end
    @report.destroy
    redirect_to reports_url
  end

  def create_pdf
    respond_with do |format|
      format.html { redirect_to reports_url }
      format.pdf do
        # only allow reports for the current_user or reports that an admin created for all users:
        report = Report.where('(for_all_users = ? OR user_id = ?) AND id = ?', true, current_user.id, params[:id]).first
        queued = false
        pdf = Pdf.new
        pdf.user_id = current_user.id
        pdf.report_id = report.id
        pdf.pdf_type = 1
        pdf.creation_criteria = report.report_criteria
        pdf.save!
        begin
          if Resque.info[:workers] > 0
            # note: if Redis is running then Resque can enqueue, but results in a bunch of jobs waiting for workers, 
            #       so we ensure that at least one worker has been started.
            Resque.enqueue(PdfWorker, current_user.id, pdf.id)
            queued = true
          end
        rescue Exception => e
          queued = false
        end
        if queued
          redirect_to events_url(q: report.report_criteria), notice: "Your PDF document is being prepared, and in a few moments it will be available for download on the PDFs page."
        else
          pdf.destroy
          redirect_to events_url(q: report.report_criteria), notice: "Background processing is offline, so PDF creation is not possible at this time."
        end
        # the following code immediately generates a PDF for downloading ... this is too time-consuming:
        # get_events_based_on_groups_for_current_user
        # pdf = EventsPdf.new(@events, params[:q])
        # # send_data pdf.render, filename: "events_report", type: "application/pdf", disposition: "inline"
        # send_data pdf.render, filename: "events_report", type: "application/pdf"
      end
    end
  end

  private

  def pulse
    set_time_range(@report.report_criteria[:relative_date_range])
    if @start_time.nil? || @end_time.nil?
      # use custom/fixed date range:
      @start_time = Time.parse("#{@report.report_criteria[:timestamp_gte]} 00:00:00 +0000")
      @end_time = Time.parse("#{@report.report_criteria[:timestamp_lte]} 23:59:59 +0000")
    end
    # note: if current_user is an admin, groups/memberships don't matter since an admin can do anything:
    if current_user.role? :admin
      # every 15 minutes (900 seconds = 15  * 60):
      @hot_times = Event.find_by_sql ["SELECT SEC_TO_TIME(FLOOR(TIME_TO_SEC(timestamp)/900)*900) AS `minute`, count(*) as `cnt` from event where timestamp BETWEEN ? AND ? GROUP BY SEC_TO_TIME(FLOOR(TIME_TO_SEC(timestamp)/900)*900) HAVING `cnt` > 10", @start_time, @end_time]
      @priorities = SignatureDetail.select("#{SignatureDetail.table_name}.sig_priority, COUNT(#{SignatureDetail.table_name}.sig_priority) as priority_cnt").where("sig_priority IS NOT NULL").group(:sig_priority).joins(:events).order('sig_priority asc')
      @priorities = @priorities.where('timestamp between ? and ?', @start_time, @end_time)
      @attackers = Iphdr.select("#{Iphdr.table_name}.ip_src, COUNT(#{Iphdr.table_name}.ip_src) AS ipcnt").group('iphdr.sid', 'iphdr.ip_src')
      @attackers = @attackers.joins(:events).where('timestamp between ? and ?', @start_time, @end_time).limit(10)
      @targets = Iphdr.select("#{Iphdr.table_name}.ip_dst, COUNT(#{Iphdr.table_name}.ip_dst) as ipcnt").group('iphdr.sid', 'iphdr.ip_dst')
      @targets = @targets.joins(:events).where('timestamp between ? and ?', @start_time, @end_time).limit(10)
      @events_by_signature = SignatureDetail.select("#{SignatureDetail.table_name}.sig_id, #{SignatureDetail.table_name}.sig_name, COUNT(#{SignatureDetail.table_name}.sig_name) as event_cnt").group(:sig_id, :sig_name).joins(:events).order('event_cnt desc').limit(10)
      @events_by_signature = @events_by_signature.where('timestamp between ? and ?', @start_time, @end_time)
      @events_count = @events_by_signature.length
    else
      # get current_user's Sensors based on group memberships:
      sensors_for_user = current_user.sensors
      if sensors_for_user.blank?
        @events_by_signature = []
        flash.now[:error] = "No sensors were found for you, perhaps you are not a member of any group. Please contact an administrator to resolve this issue."
        @events_count = 0
        return
      else
        # every 15 minutes (900 seconds = 15  * 60):
        @hot_times = Event.find_by_sql ["SELECT SEC_TO_TIME(FLOOR(TIME_TO_SEC(timestamp)/900)*900) AS `minute`, count(*) as `cnt` from event where event.sid IN (?) AND timestamp BETWEEN ? AND ? GROUP BY SEC_TO_TIME(FLOOR(TIME_TO_SEC(timestamp)/900)*900) HAVING `cnt` > 10", sensors_for_user, @start_time, @end_time]
        @priorities = SignatureDetail.select("#{SignatureDetail.table_name}.sig_priority, COUNT(#{SignatureDetail.table_name}.sig_priority) as priority_cnt").where("sig_priority IS NOT NULL").group(:sig_priority).joins(:events).where("event.sid IN (?)", sensors_for_user).order('sig_priority asc')
        @priorities = @priorities.where('timestamp between ? and ?', @start_time, @end_time)
        @attackers = Iphdr.where("iphdr.sid IN (?)", sensors_for_user).select("#{Iphdr.table_name}.ip_src, COUNT(#{Iphdr.table_name}.ip_src) as ipcnt").group('iphdr.sid', 'iphdr.ip_src')
        @attackers = @attackers.joins(:events).where('timestamp between ? and ?', @start_time, @end_time).limit(10)
        @targets = Iphdr.where("iphdr.sid IN (?)", sensors_for_user).select("#{Iphdr.table_name}.ip_dst, COUNT(#{Iphdr.table_name}.ip_dst) as ipcnt").group('iphdr.sid', 'iphdr.ip_dst')
        @targets = @targets.joins(:events).where('timestamp between ? and ?', @start_time, @end_time).limit(10)
        @events_by_signature = SignatureDetail.select("#{SignatureDetail.table_name}.sig_id, #{SignatureDetail.table_name}.sig_name, COUNT(#{SignatureDetail.table_name}.sig_name) as event_cnt").group(:sig_id, :sig_name).joins(:events).where("event.sid IN (?)", sensors_for_user)
        @events_by_signature = @events_by_signature.where('timestamp between ? and ?', @start_time, @end_time).order('event_cnt desc').limit(10)
        @events_count = @events_by_signature.length
      end
    end
  end
end
