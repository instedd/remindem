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

class Channel < ActiveRecord::Base
  belongs_to :user

  after_save    { user.telemetry_track_activity }
  after_destroy { user.telemetry_track_activity }
  
  before_destroy :remove_channel_from_nuntium
  
  def remove_channel_from_nuntium
    Nuntium.new_from_config.delete_channel name
  end
  
end
