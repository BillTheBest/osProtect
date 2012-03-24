class NotificationResultsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :ensure_user_is_setup

  def index
    @notification = current_user.notifications.find(params[:id])
    @notification_results = @notification.notification_results.order("updated_at desc").page(params[:page]).per_page(APP_CONFIG[:per_page])
  end

  def show
    # show matching events for this notification result:
    @notification_result = current_user.notification_results.find(params[:id])
    @notification = Notification.find(@notification_result.notification.id)
    # @events = @notification_result.result_ids.map { |id| Event.find(id) }
    sids = @notification_result.result_ids.map{|r| r[0]}
    cids = @notification_result.result_ids.map{|r| r[1]}
    @events = Event.where(sid: sids, cid: cids).page(params[:page]).per_page(APP_CONFIG[:per_page])
  end

  def new
    redirect_to notification_results_url
  end

  def create
    redirect_to notification_results_url
  end

  def edit
    redirect_to notification_results_url
  end

  def update
    redirect_to notification_results_url
  end

  def destroy
    @notification_result = current_user.notification_results.find(params[:id])
    notification_id = @notification_result.notification.id
    @notification_result.destroy
    redirect_to notification_results_url(id: notification_id)
  end
end
