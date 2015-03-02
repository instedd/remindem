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

class SchedulesController < AuthenticatedController

  def initialize
    super
    @show_breadcrumb = true
    add_breadcrumb _("Reminders"), :schedules_path
  end

  # GET /schedules
  # GET /schedules.xml
  def index
    @at_least_one_schedule_is_paused = !Schedule.where(:user_id => current_user.id, :paused => true).empty?

    @schedules = if params[:show] == 'all' || params[:show].nil?
        Schedule.where(:user_id => current_user.id)
      else
        Schedule.where(:user_id => current_user.id, :paused => params[:show] == 'paused')
      end

    @last_log = Log.find(:all, :conditions => ["schedule_id in (?)", @schedules.collect(&:id)]).sort_by(&:created_at).reverse.first rescue nil
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @schedules }
    end
  end

  # GET /schedules/1
  # GET /schedules/1.xml
  def show
    @schedule = Schedule.find(params[:id])
    add_breadcrumb @schedule.title, schedule_path(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @schedule }
    end
  end

  # GET /schedules/new
  # GET /schedules/new.xml
  def new
    add_breadcrumb _("New Reminder"), :new_schedule_path
    @schedule = FixedSchedule.new :timescale => "hours"

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @schedule }
    end
  end

  # GET /schedules/1/edit
  def edit
    @schedule = Schedule.find(params[:id])
    add_breadcrumb @schedule.title, schedule_path(params[:id])
    add_breadcrumb _("Settings"), edit_schedule_path(params[:id])
    @schedule.sort_messages
  end

  # POST /schedules
  # POST /schedules.xml
  def create
    params[:schedule][:user] = current_user
    @schedule = params[:schedule][:type].constantize.new(params[:schedule])

    respond_to do |format|
      if @schedule.save
        format.html { redirect_to(schedule_url(@schedule), :notice => _('Schedule was successfully created.')) }
        format.xml  { render :xml => @schedule, :status => :created, :location => @schedule }
      else
        add_breadcrumb _("New Reminder"), :new_schedule_path
        format.html { render :action => "new" }
        format.xml  { render :xml => @schedule.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /schedules/1
  # PUT /schedules/1.xml
  def update
    @schedule = Schedule.find(params[:id])

    #Type needs to be manually set because it's protected, thus update_attributes doesn't affect it
    @schedule.type = params[:schedule][:type] unless params[:schedule][:type].blank?

    parse_nested_attributes_for_actions(params[:schedule][:external_actions_attributes])

    respond_to do |format|
      if @schedule.update_attributes(params[:schedule])
        format.html { redirect_to(schedule_url(@schedule), :notice => _('Schedule was successfully updated.')) }
        format.xml  { head :ok }
      else
        add_breadcrumb @schedule.title, schedule_path(params[:id])
        add_breadcrumb _("Settings"), edit_schedule_path(params[:id])

        format.html { render :action => "edit" }
        format.xml  { render :xml => @schedule.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /schedules/1
  # DELETE /schedules/1.xml
  def destroy
    @schedule = Schedule.find(params[:id])
    if params[:notify] == "true"
      @schedule.notifySubscribers = true
    else
      @schedule.notifySubscribers = false
    end
    @schedule.destroy

   respond_to do |format|
     format.html { redirect_to(schedules_url, :notice => _('Schedule was successfully deleted.')) }
     format.xml  { head :ok }
   end
  end

  private

  def parse_nested_attributes_for_actions(attributes)
    modified_attrs = {}
    attributes.each do |key, attrs|
      modified_attrs[key] = attrs
      modified_attrs[key][:external_actions] = JSON.parse(modified_attrs[key][:external_actions])
    end
    puts modified_attrs
    modified_attrs
  end
end
