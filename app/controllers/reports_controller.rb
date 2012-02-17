# note: we are doing explicit require's and include's so it is clear as to what is going on, and
#       just in case some brave soul will try to run this app in thread safe mode
# require "#{Rails.root}/lib/osprotect/restrict_events_based_on_users_access"
require "osprotect/restrict_events_based_on_users_access"

class ReportsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :ensure_user_is_setup

  include Osprotect::RestrictEventsBasedOnUsersAccess

  def events_listing
    @report = Report.where('(for_all_users = ? OR user_id = ?) AND id = ?', true, current_user.id, params[:id]).first
    get_events_based_on_groups_for_user(current_user.id) # sets @events
    filter_events_based_on(params[:q]) # sets @event_search
    @events = @events.page(params[:page]).per_page(12)
  end

  def index
    # only show reports for the current_user or reports that an admin created for all users:
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
    @report = Report.new(params[:report])
    @report.user_id = current_user.id
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
    @report.destroy
    redirect_to reports_url
  end
end
