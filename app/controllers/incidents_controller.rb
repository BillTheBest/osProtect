class IncidentsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :ensure_user_is_setup

  def index
    @incidents = Incident.order("updated_at desc").page(params[:page]).per_page(5)
  end

  def show
    redirect_to incidents_url
    # @incident = Incident.find(params[:id])
  end

  def new
    @incident = Incident.new
  end

  def create
    @incident = Incident.new(params[:incident])
    if @incident.save
      redirect_to incidents_url, notice: 'Incident was successfully created.'
    else
      render action: "new"
    end
  end

  def edit
    @incident = Incident.find(params[:id])
    # add pagination: @incident_events = @incident.incident_events.page(params[:page]).per_page(12)
  end

  def update
    @incident = Incident.find(params[:id])
    if @incident.update_attributes(params[:incident])
      redirect_to incidents_url, notice: 'Incident was successfully updated.'
    else
      render action: "edit"
    end
  end

  def destroy
    @incident = Incident.find(params[:id])
    @incident.destroy
    redirect_to incidents_url
  end
end
