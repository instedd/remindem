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

class ChannelController < AuthenticatedController

  def new
  end

  def create
    unless params[:show_local_gateway]
      @channel = current_user.register_channel params[:channel][:code]
      params[:step] = "end_wizard"
      render :action => "new"
    end
  rescue Nuntium::Exception => exception
    @invalid_channel = Channel.new
    load_errors_from exception
    params[:step] = params[:channel][:step]
    render :action => "new"
  end

  # DELETE /channels/1
  # DELETE /channels/1.xml
  def destroy
    @channel = Channel.where(user_id: current_user.id).find(params[:id])
    @channel.destroy

    respond_to do |format|
      format.html { redirect_to(schedules_url, :notice => _('Channel was successfully deleted.')) }
      format.xml  { head :ok }
    end
  rescue Nuntium::Exception => exception
    load_errors_from exception
    params[:step] = "user_channel"
    render :action => "new"
  end

  def load_errors_from exception
    if exception.properties.empty?
      @invalid_channel.errors.add(_('Unexpected Error: '), "\"#{exception.message}\"")
    end
    exception.properties.map do |value, msg|
      @invalid_channel.errors.add(("#{value.humanize}: "), msg)
    end
  end

end
