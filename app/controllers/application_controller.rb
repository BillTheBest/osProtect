class ApplicationController < ActionController::Base
  protect_from_forgery

  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = "Access denied."
    redirect_to root_url
  end

  protected

  # def present_page_of(collection, options = {})
  #   presenter = page_presenter_class.new(self, page_of(collection))
  #   respond_with presenter, options
  # end
  # 
  # def page_of(collection)
  #   collection.paginate(:page => params[:page], :per_page => 12)
  # end
  # 
  # def page_presenter_class
  #   (self.class.name.gsub!("Controller", "").singularize + "PagePresenter").constantize
  # end
  # 
  # def presenter_class
  #   (self.class.name.gsub!("Controller", "").singularize + "Presenter").constantize
  # end


  private

  def menu_tabs
    return ['events', 'incidents', 'pulse', 'sensors', 'groups', 'users', 'resque_server'] if can? :admin, User
    ['events', 'incidents', 'pulse', 'sensors']
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
