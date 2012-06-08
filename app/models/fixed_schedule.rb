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

class FixedSchedule < Schedule
  validates_presence_of :timescale
  
  def sort_messages
    messages.sort_by!(&:offset)
  end
  
  def expected_delivery_time message, subscriber
    subscriber.reference_time + message.offset.send(self.timescale.to_sym)
  end
  
  def reminders
    self.messages.all
  end
  
  def enqueue_reminder message, index, recipient
    schedule_message message, recipient, expected_delivery_time(message, recipient)
  end
  
  def self.mode_in_words
    _("Timeline")
  end
  
  def duration
    if messages.empty?
      0
    else
      sort_messages.last.offset
    end
  end
  
end