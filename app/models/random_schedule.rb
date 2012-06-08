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

class RandomSchedule < Schedule
  validates_presence_of :timescale
  
  def sort_messages
    messages.sort_by!( &:created_at)
  end

  def reminders
    self.messages.all.shuffle!
  end
  
  def enqueue_reminder message, index, recipient
    #this doesn't actually send once a day...
    schedule_message message, recipient, index.send(self.timescale.to_sym).from_now
  end
  
  def self.mode_in_words
    _("Random")
  end
  
  def duration
    self.messages.size
  end
  
end