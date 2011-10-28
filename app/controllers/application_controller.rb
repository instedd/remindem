class ApplicationController < ActionController::Base

  rescue_from ActionController::RoutingError, :with => :render_404
  
  protect_from_forgery

  def after_sign_in_path_for user
  	schedules_path
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
end
