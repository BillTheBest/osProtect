class SensorPagePresenter < BasePresenter
  include Rails.application.routes.url_helpers

  presents :sensors

  def page_of_sensors
    sensors.page(params[:page]).per_page(12)
  end
  # memoize :page_of_sensors # deprecated rails 3.2.0
end