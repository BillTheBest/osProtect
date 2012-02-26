class SensorPagePresenter < BasePresenter
  include Rails.application.routes.url_helpers

  presents :sensors

  def page_of_sensors
    sensors.page(params[:page]).per_page(APP_CONFIG[:per_page])
  end
end