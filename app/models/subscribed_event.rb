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

class SubscribedEvent < Struct.new(:subscriber_id)
  def perform
    subscriber = Subscriber.find(self.subscriber_id)
    HubClient.current.notify "schedules/#{subscriber.schedule_id}/subscribers/$events/new_subscriber", subscriber.to_json
  rescue ActiveRecord::RecordNotFound
    #If the record doesn't exist it's because the schedule was deleted, in which case no further messages must be sent.
  end
end
