class IncidentsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :ensure_user_is_setup

  def index
    @incidents = Incident.accessible_by(current_ability).order("updated_at desc").page(params[:page]).per_page(12)
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
    # FIXME any group that current_user is a member of will do, but if current_user's
    #       groups/members are changed this could lead to zombie incidents:
    @incident.group_id = current_user.groups.first.id
    if @incident.save
      redirect_to incidents_url, notice: 'Incident was successfully created.'
    else
      render action: "new"
    end
  end

  def edit
    @incident = Incident.accessible_by(current_ability).find(params[:id])
    # add pagination: @incident_events = @incident.incident_events.page(params[:page]).per_page(12)
  end

  def update
    @incident = Incident.accessible_by(current_ability).find(params[:id], readonly: false)
    # FIXME any group that current_user is a member of will do, but if current_user's
    #       groups/members are changed this could lead to zombie incidents:
    @incident.group_id = current_user.groups.first.id unless current_user.role? :admin # don't change owner
    if @incident.update_attributes(params[:incident])
      redirect_to incidents_url, notice: 'Incident was successfully updated.'
    else
      render action: "edit"
    end
  end

  def destroy
    @incident = Incident.accessible_by(current_ability).find(params[:id])
    @incident.destroy
    redirect_to incidents_url
  end
end
