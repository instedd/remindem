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

require 'machinist/active_record'
require 'sham'
require 'ffaker'

Sham.email { Faker::Internet.email }
Sham.password { SecureRandom.base64(6) }
Sham.keyword { Faker::Lorem.word }
Sham.phone_number { rand(36**8).to_s.with_protocol }
Sham.body { "Message" + rand(265**1).to_s }
Sham.severity { [:information, :error, :warning].pick }
Sham.description { Faker::Lorem.sentence }
Sham.title { Faker::Lorem.words(2) }

Log.blueprint do
  severity
  description
  schedule { [RandomSchedule, FixedSchedule, CalendarBasedSchedule].pick.make }
end

User.blueprint do
  email
  password
end

Schedule.blueprint do
  user
  title
  paused { false }
  keyword
  welcome_message { Faker::Lorem.sentence }
end

FixedSchedule.blueprint do
  timescale { Schedule.time_scale_options[rand(Schedule.time_scale_options.count)][1] }
end

RandomSchedule.blueprint do
  timescale { Schedule.time_scale_options[rand(Schedule.time_scale_options.count)][1] }
end

CalendarBasedSchedule.blueprint do
end

Subscriber.blueprint do
  phone_number
  subscribed_at { Time.now.utc }
  offset { 0 }
end

ExternalAction.blueprint do
  schedule_id { FixedSchedule.make.id }
  offset { 1 }
end
