class ApplicationController < ActionController::Base
  protect_from_forgery

  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = "Access denied."
    redirect_to root_url
  end

  private

  def menu_tabs
    tabs = ['events', 'pulse', 'incidents', 'sensors']
    tabs += ['notifications'] if APP_CONFIG[:can_do_notifications]
    tabs += ['reports', 'pdfs'] if APP_CONFIG[:can_do_reports]
    tabs += ['groups', 'users'] if can?(:admin, User)
    tabs += ['resque_server'] if can?(:admin, User) && (APP_CONFIG[:can_do_notifications] || APP_CONFIG[:can_do_reports])
    tabs
  end
  helper_method :menu_tabs

  def current_user_is_an_app_admin?
    false
  end
  helper_method :current_user_is_admin?

  def current_user_is_not_an_app_admin?
    true
  end
  helper_method :current_user_is_not_an_app_admin?

  def current_user
    @current_user ||= User.find_by_auth_token!(cookies[:auth_token]) if cookies[:auth_token]
  end
  helper_method :current_user

  def authenticate_user!
    if current_user.nil?
      if request.url =~ /login/i || request.url =~ /logout/i
        session[:ref] = nil
      else
        session[:ref] = request.url
      end
      redirect_to login_url, :alert => "You must first log in to access this page!"
    end
  end

  def ensure_user_is_setup
    return if current_user.role? :admin
    unless current_user.has_sensors?
      flash[:error] = "No sensors were found for your account, perhaps you are not a member of any group. Please contact an administrator to resolve this issue."
      redirect_to user_setup_required_url
    end
  end
end
