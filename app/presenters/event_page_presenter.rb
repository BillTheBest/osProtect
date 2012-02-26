class EventPagePresenter < BasePresenter
  include Rails.application.routes.url_helpers

  presents :events

  def page_of_events
    # events.page(params[:page]).per_page(APP_CONFIG[:per_page])
    events
  end
end