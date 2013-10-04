# Copyright (C) 2011-2012, InSTEDD
#
# This file is part of Remindem.
#
# Remindem is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Remindem is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Remindem.  If not, see <http://www.gnu.org/licenses/>.

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

  def show_breadcrumb
    @show_breadcrumb = true
  end

end
