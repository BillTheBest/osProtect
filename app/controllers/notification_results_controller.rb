class NotificationResultsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :ensure_user_is_setup

  def index
    @notification = current_user.notifications.find(params[:id])
    @notification_results = @notification.notification_results.order("updated_at desc").page(params[:page]).per_page(12)
  end

  def show
    # show matching events for this notification result:
    @notification_result = current_user.notification_results.find(params[:id])
    @notification = NotificationResult.find(params[:id])
    # @notifications = current_user.notifications.order("updated_at desc").page(params[:page]).per_page(12)
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
    notification = @notification_result.id
    @notification_result.destroy
    redirect_to notification_results_url(id: notification)
  end
end
