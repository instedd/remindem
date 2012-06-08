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

class LogsController < AuthenticatedController
  helper_method :sort_column, :sort_direction
  
  def initialize
    super
    @show_breadcrum = true
    add_breadcrumb _("Reminders"), :schedules_path
  end  
  
  # GET /logs
  # GET /logs.xml
  def index
    add_breadcrumb Schedule.find(params[:schedule_id]).title, schedule_path(params[:schedule_id])
	  add_breadcrumb _("Logs"), schedule_logs_path(params[:schedule_id])

    @logs =Log.where(:schedule_id => params[:schedule_id]).page(params[:page]).per(10).order(sort_column + " " + sort_direction)
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @logs }
    end
  end
  
  def sort_column
     Log.column_names.include?(params[:sort]) ? params[:sort] : "created_at"
  end

  def sort_direction
     %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
  end
end
