class ReportsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :ensure_user_is_setup

  def index
    @reports = current_user.reports.order("updated_at desc").page(params[:page]).per_page(12)
  end

  def show
    redirect_to reports_url
    # @report = Report.find(params[:id])
  end

  def new
    @report = Report.new
    @event_search = EventSearch.new(nil)
  end

  def create
    @report = Report.new(params[:report])
    @report.user_id = current_user.id
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
    # handle any filter/search criteria, if provided:
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
