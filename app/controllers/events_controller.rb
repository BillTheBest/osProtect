class EventsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :ensure_user_is_setup

  respond_to :html
  respond_to :js, only: :create
  respond_to :pdf, only: [:index, :create_pdf]

  def index
    get_events_based_on_groups_for_current_user
  end

  def show
    respond_with do |format|
      format.html do
        @event = Event.includes(:sensor, :signature_detail, :iphdr, :tcphdr, :icmphdr, :udphdr, :payload).find(params[:id])
      end
      format.pdf do
        pdf = EventsPdf.new
        send_data pdf.render, filename: "events_report_#{3}", type: "application/pdf", disposition: "inline"
        return
      end
    end
  end

  def create
    # this action will create/append selected events to a new/existing Incident
    return if params.blank?
    return if params[:event].blank?
    incident_id = params[:incident_id].blank? ? 0 : params[:incident_id].to_i
    @incident = Event.add_events_to_incident(incident_id, params[:event], current_user)
    respond_with @incident, :location => events_url
  end

  def create_pdf
    # Resque.enqueue(TestWorker, 1, "Major Spudmeister")
    respond_with do |format|
      format.html { redirect_to events_url }
      format.pdf do
        get_events_based_on_groups_for_current_user
        pdf = EventsPdf.new(@events, params[:q])
        # send_data pdf.render, filename: "events_report", type: "application/pdf", disposition: "inline"
        send_data pdf.render, filename: "events_report", type: "application/pdf"
      end
    end
  end

  private

  def get_events_based_on_groups_for_current_user
    # note: if current_user is an admin, groups/memberships don't matter since an admin can do anything:
    if current_user.role? :admin
      @events = Event.includes(:sensor, :signature_detail, :iphdr, :tcphdr, :udphdr).order("timestamp desc")
      # @events = Event.includes(:iphdr).order("timestamp desc")
      # @events = Iphdr.includes(:events).order("event.timestamp desc")
    else
      # use current_user's sensors based on group memberships:
      @events = Event.where("event.sid IN (?)", current_user.sensors).includes(:sensor, :signature_detail, :iphdr, :tcphdr, :udphdr).order("timestamp desc")
    end
    # handle any filter/search criteria, if provided:
    @event_search = EventSearch.new(params[:q])
    if params.present?
      if params[:commit] == 'Reset'
        @event_search.reset_search
        redirect_to events_path
      end
      # if any errors just return and the filter form will display them:
      return if @event_search.errors.size > 0
      # otherwise let's apply the filter/search criteria to the events relation:
      @events = @event_search.filter @events
    end
  end
end
