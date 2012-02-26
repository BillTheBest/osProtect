# note: we are doing explicit require's and include's so it is clear as to what is going on, and
#       just in case some brave soul will try to run this app in thread safe mode
# require "#{Rails.root}/lib/osprotect/restrict_events_based_on_users_access"
require "osprotect/restrict_events_based_on_users_access"

class EventsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :ensure_user_is_setup

  respond_to :html
  respond_to :js, only: :create
  respond_to :pdf, only: [:index, :create_pdf]

  include Osprotect::RestrictEventsBasedOnUsersAccess

  def index
    # get_events_based_on_groups_for_user(current_user.id)
    # letting CanCan fetch records based on the current_user's abilities is cleaner (see: models/ability.rb file):
    @events = Event.includes(:sensor, :signature_detail, :iphdr, :tcphdr, :udphdr).accessible_by(current_ability).order("timestamp desc").page(params[:page]).per_page(APP_CONFIG[:per_page])
    filter_events_based_on(params[:q])
    if params.present?
      if params[:commit] == 'Reset'
        @event_search.reset_search
        redirect_to events_path
      end
    end
  end

  def show
    respond_with do |format|
      format.html do
        @event = Event.includes(:sensor, :signature_detail, :iphdr, :tcphdr, :icmphdr, :udphdr, :payload).find(params[:id])
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
    respond_with do |format|
      format.html { redirect_to events_url }
      format.pdf do
        queued = false
        pdf = Pdf.new
        pdf.user_id = current_user.id
        pdf.pdf_type = 3
        pdf.creation_criteria = params[:q]
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
          redirect_to events_url(q: params[:q]), notice: "Your PDF document is being prepared, and in a few moments it will be available for download on the PDFs page."
        else
          pdf.destroy
          redirect_to events_url(q: params[:q]), notice: "Background processing is offline, so PDF creation is not possible at this time."
        end
      end
    end
  end
end
