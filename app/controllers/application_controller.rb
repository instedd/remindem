class ApplicationController < ActionController::Base
  protect_from_forgery
  def after_sign_in_path_for user
  	schedules_path
  end
  
  private

  def add_body_class(new_class)
    @body_class ||= []
    @body_class << new_class
  end
  
end
