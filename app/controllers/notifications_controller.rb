class NotificationsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :ensure_user_is_setup

  def index
    @notifications = current_user.notifications.order("updated_at desc").page(params[:page]).per_page(12)
  end

  def show
    redirect_to notifications_url
    # @notification = Notification.find(params[:id])
  end

  def new
    @notification = Notification.new
  end

  def create
    @notification = Notification.new(params[:notification])
    @notification.notify_criteria = NotificationCriteria.new
    @notification.user_id = current_user.id
    if @notification.save
      redirect_to @notification, notice: 'Notification was successfully created, and you will receive an email when your is matched.'
    else
      render action: "new"
    end
  end

  def edit
    @notification = current_user.notifications.find(params[:id])
  end

  def update
    @notification = current_user.notifications.find(params[:id])
    if @notification.update_attributes(params[:notification])
      redirect_to @notification, notice: 'Notification was successfully updated.'
    else
      render action: "edit"
    end
  end

  def destroy
    @notification = current_user.notifications.find(params[:id])
    @notification.destroy
    redirect_to notifications_url
  end
end
