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

class SubscribersController < AuthenticatedController
  helper_method :sort_column, :sort_direction
    
  def initialize
    super
    @show_breadcrum = true
    add_breadcrumb _("Reminders"), :schedules_path
  end
  
  
  # GET /subscribers
  # GET /subscribers.xml
  def index
    add_breadcrumb Schedule.find(params[:schedule_id]).title, schedule_path(params[:schedule_id])
    add_breadcrumb _("Subscribers"), schedule_subscribers_path(params[:schedule_id])
    @subscribers = Subscriber.where(:schedule_id => params[:schedule_id]).page(params[:page]).per(10).order(sort_column + " " + sort_direction)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @subscribers }
      format.csv do
        @subscribers = Subscriber.where(:schedule_id => params[:schedule_id])
        render :csv => @subscribers
      end
    end
  end

  # DELETE /subscribers/1
  # DELETE /subscribers/1.xml
  def destroy
    @subscriber = Subscriber.find(params[:id])
    @subscriber.destroy

    respond_to do |format|
      format.html { redirect_to(schedule_subscribers_url, :schedule_id => params[:schedule_id]) }
      format.xml  { head :ok }
    end
  end
  
  def sort_column
     Subscriber.column_names.include?(params[:sort]) ? params[:sort] : "subscribed_at"
  end

  def sort_direction
     %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
  end
end
