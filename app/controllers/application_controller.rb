class ApplicationController < ActionController::Base

  rescue_from ActionController::RoutingError, :with => :render_404
  
  protect_from_forgery

  before_filter :set_gettext_locale
  before_filter :redirect_to_localized_url

  def after_sign_in_path_for user
    if user.lang
      I18n.locale = user.lang.to_sym 
    elsif I18n.locale
      user.lang = I18n.locale.to_s
      user.save
    end
    (session[:return_to] || schedules_path).to_s
  end
  
  def render_404
    respond_to do |type| 
      type.html { render :template => "errors/error_404", :status => 404, :layout => 'application' } 
      type.all  { render :nothing => true, :status => 404 } 
    end
    true
  end

  private

  def add_body_class(new_class)
    @body_class ||= []
    @body_class << new_class
  end
  
  def redirect_to_localized_url
    redirect_to params if params[:locale].nil? && request.get?
  end
  
  def default_url_options(options={})
    {:locale => I18n.locale.to_s}
  end
  
end
