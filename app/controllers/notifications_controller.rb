class NotificationsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :ensure_user_is_setup
  before_filter :can_do_notifications

  def index
    @title = "Notifications"
    @notifications = current_user.notifications.order("updated_at desc").page(params[:page]).per_page(APP_CONFIG[:per_page])
  end

  def show
    redirect_to notifications_url
  end

  def new
    @notification = Notification.new
    @event_search = EventSearch.new(nil)
  end

  def create
    @notification = Notification.new(params[:notification])
    adjust_attributes
    if @notification.save
      redirect_to @notification, notice: 'Notification was successfully created, and you will receive an email when matches occur.'
    else
      @event_search = EventSearch.new(params[:q])
      render action: "new"
    end
  end

  def edit
    @title = "Edit Notification"
    @notification = current_user.notifications.find(params[:id])
    @event_search = EventSearch.new(@notification.notify_criteria)
  end

  def update
    @notification = current_user.notifications.find(params[:id])
    adjust_attributes
    if @notification.update_attributes(params[:notification])
      redirect_to @notification, notice: 'Notification was successfully updated.'
    else
      @event_search = EventSearch.new(params[:q])
      render action: "edit"
    end
  end

  def destroy
    @notification = current_user.notifications.find(params[:id])
    @notification.destroy
    redirect_to notifications_url
  end

  private

  def can_do_notifications
    return if APP_CONFIG[:can_do_notifications]
    flash[:error] = "Access denied: Notifications are not available."
    redirect_to root_url
  end

  def adjust_attributes
    # ignore date ranges by resetting them:
    params[:q][:relative_date_range] = ""
    params[:q][:timestamp_gte] = ""
    params[:q][:timestamp_lte] = ""
    @notification.user_id = current_user.id if @notification.user_id.blank? # preserve the original creator/owner id
    @notification.notify_criteria = params[:q]
  end
end
