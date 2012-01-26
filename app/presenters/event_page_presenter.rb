class EventPagePresenter < BasePresenter
  include Rails.application.routes.url_helpers

  presents :events

  def page_of_events
    events.page(params[:page]).per_page(12)
    # events.includes(:sensor, :signature_detail, :iphdr, :tcphdr, :udphdr)
    # Event.paginate_by_sql(events.to_sql, page: params[:page], per_page: 12)
  end
  # memoize :page_of_events # deprecated rails 3.2.0
end