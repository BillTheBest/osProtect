# note: we are doing explicit require's and include's so it is clear as to what is going on, and
#       just in case some brave soul will try to run this app in thread safe mode
require "osprotect/restrict_events_based_on_users_access"
require "osprotect/date_ranges"
require "osprotect/pulse_top_tens"

class ReportsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :ensure_user_is_setup
  before_filter :can_do_reports

  include Osprotect::RestrictEventsBasedOnUsersAccess
  include Osprotect::DateRanges
  include Osprotect::PulseTopTens

  respond_to :html
  respond_to :pdf, only: [:create_pdf]

  def index
    # list reports for current_user, or current_user.groups, or admin created for all users:
    if current_user.role?(:admin)
      @reports = Report
    else
      # note if 'user_id = current_user.id' then this user is the owner of this report or 
      # the user set this report with 'Access Allowed' 'To' 'only me' (but they are still the owner)
      @reports = Report.where('for_all_users = ? OR user_id = ?', true, current_user.id)
      @reports = Report.includes(:groups).where('groups.id IN (?)', current_user.groups) if @reports.blank?
    end
    @reports = @reports.order("reports.updated_at desc").page(params[:page]).per_page(APP_CONFIG[:per_page])
  end

  def show
    redirect_to reports_url
  end

  def new
    @report = Report.new
    @report.report_type = 2 if params[:commit] == 'create Incidents Report' # incidents
    @event_search = @report.report_type == 2 ? IncidentEventSearch.new(nil) : EventSearch.new(nil)
  end

  def create
    adjust_params
    @report = Report.new(params[:report])
    adjust_report_attributes
    if @report.save
      redirect_to @report, notice: 'Report was successfully created.'
    else
      @event_search = @report.report_type == 2 ? IncidentEventSearch.new(params[:q]) : EventSearch.new(params[:q])
      render action: "new"
    end
  end

  def edit
    @report = current_user.reports.find(params[:id])
    @event_search = @report.report_type == 2 ? IncidentEventSearch.new(@report.report_criteria) : EventSearch.new(@report.report_criteria)
  end

  def update
    adjust_params
    @report = current_user.reports.find(params[:id])
    adjust_report_attributes
    if @report.update_attributes(params[:report])
      redirect_to @report, notice: 'Report was successfully updated.'
    else
      @event_search = @report.report_type == 2 ? IncidentEventSearch.new(params[:q]) : EventSearch.new(params[:q])
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

  # HTML version of report
  def events_listing
    if current_user.role?(:admin)
      @report = Report.find(params[:id])
    else
      @report = Report.where('(for_all_users = ? OR user_id = ?) AND id = ?', true, current_user.id, params[:id]).first
      @report = Report.includes(:groups).where('groups.id IN (?)', current_user.groups).first if @reports.blank?
    end
    if @report.blank?
      redirect_to reports_url, notice: "Access denied."
      return
    end
    get_events_based_on_groups_for_user(current_user.id) # sets @events
    filter_events_based_on(params[:q]) # sets @event_search
    @events = @events.page(params[:page]).per_page(APP_CONFIG[:per_page])
    set_pulse_for_partial
  end

  # PDF version of report
  def create_pdf
    respond_with do |format|
      format.html { redirect_to reports_url }
      format.pdf do
        # only allow reports for the current_user or reports that an admin created for all users:
        if current_user.role?(:admin)
          report = Report.find(params[:id])
        else
          report = Report.where('(for_all_users = ? OR user_id = ?) AND id = ?', true, current_user.id, params[:id]).first
          report = Report.includes(:groups).where('groups.id IN (?)', current_user.groups).first if @reports.blank?
        end
        if report.blank?
          redirect_to reports_url, notice: "Access denied."
          return
        end
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
          # redirect_to events_url(q: report.report_criteria), notice: "Your PDF document is being prepared, and in a few moments it will be available for download on the PDFs page."
          redirect_to reports_url, notice: "Your PDF document is being prepared, and in a few moments it will be available for download on the PDFs page."
        else
          pdf.destroy
          redirect_to reports_url, notice: "Background processing is offline, so PDF creation is not possible at this time."
        end
      end
    end
  end

  private

  def can_do_reports
    return if APP_CONFIG[:can_do_reports]
    flash[:error] = "Access denied: Reports are not available."
    redirect_to root_url
  end

  def adjust_params
    if ['a', 'm'].include?(params[:report][:accessible_by])
      params[:report][:group_ids] = []
    end
    auto_run_types = Report.auto_run_selections.collect {|p| p.id}
    if auto_run_types.include?(params[:report][:auto_run_at])
      # ignore date ranges by resetting them:
      params[:q][:relative_date_range] = ""
      params[:q][:timestamp_gte] = ""
      params[:q][:timestamp_lte] = ""
    end
  end

  def adjust_report_attributes
    # @report.report_type = 1 # default is 1=EventsReport
    @report.user_id = current_user.id if @report.user_id.blank? # i.e. don't lose original creator/owner id
    @report.for_all_users = false # only admins can set this to true
    @report.for_all_users = true if params[:report][:accessible_by] == 'a' && current_user.role?(:admin)
    @report.report_criteria = params[:q]
  end

  def set_pulse_for_partial
    take_pulse(current_user, @report.report_criteria[:relative_date_range])
  end
end
