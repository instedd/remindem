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

ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'mocha'
require File.expand_path('../blueprints', __FILE__)

# Initialize hub client with mock values
HubClient.current url: 'http://example.com', connector_guid: 'CONNECTOR', token: 'TOKEN', enabled: true

class ActiveSupport::TestCase

  include Mocha::API

  def pregnant_make(user=nil)
    schedule = FixedSchedule.make :keyword => 'pregnant', :timescale => 'weeks', :user => user || current_user
    schedule.messages.create! :text => 'pregnant1', :offset => 3
    schedule.messages.create! :text => 'pregnant2', :offset => 11
    schedule.messages.create! :text => 'pregnant3', :offset => 17
    schedule.messages.create! :text => 'pregnant4', :offset => 23
    schedule.messages.create! :text => 'pregnant5', :offset => 36

    Subscriber.make :schedule => schedule, :phone_number => 'sms://4000', :offset => 0
    Subscriber.make :schedule => schedule, :phone_number => 'sms://4001', :offset => 2

    return schedule
  end

  def randweeks_make(user=nil)
    schedule = RandomSchedule.make :keyword => 'randweeks', :timescale => 'weeks', :welcome_message => 'welcome', :paused => true, :user => user || current_user
    schedule.messages.create! :text => 'msg1'
    schedule.messages.create! :text => 'msg2'
    schedule.messages.create! :text => 'msg3'
    schedule.messages.create! :text => 'msg4'
    schedule.messages.create! :text => 'msg5'

    Subscriber.make :schedule => schedule, :phone_number => 'sms://5000', :offset => 0

    return schedule
  end

  def one_make(user=nil)
    schedule = RandomSchedule.make :keyword => 'one', :timescale => 'weeks', :welcome_message => 'foo', :user => user || current_user
    schedule.messages.create! :text => 'MyString'
    schedule.messages.create! :text => 'MyString'
    schedule.messages.create! :text => 'MyString'

    return schedule
  end

  def current_user
    @user ||= User.make
  end

  def disable_hub
    HubClient.current.stubs(:enabled?).returns(false)
  end

  def reenable_hub
    HubClient.current.unstub(:enabled?)
  end

  # Sets current time as a stub on Time.now
  def set_current_time(time=Time.at(946702800).utc)
    Time.stubs(:now).returns(time)
  end

  # Returns base time to be used for tests in utc
  def base_time
    return Time.at(946702800).utc
  end

  def time_advance(span)
    set_current_time(Time.now + span)
    Delayed::Worker.new.work_off
  end

  # begin mock and Assert Nuntium
  setup do
    Nuntium.stubs(:new_from_config).returns(self)
    clear_messages
  end

  def send_ao(message)
    @messages_sent = @messages_sent << message
  end

  def messages_to(phone)
    @messages_sent.find_all { |m| m[:to] == phone }
  end

  def assert_no_message_sent(phone)
    assert messages_to(phone).empty?, "The following messages were not expected to be sent #{messages_to(phone)}"
  end

  def assert_message_sent(phone, text)
    assert messages_to(phone).any? { |m| m[:body].match(text) }, "#{phone} did not receive expected message: #{text}"
  end

  def clear_messages
    @messages_sent = []
  end
  # end
end

class ActionController::TestCase
  include Devise::TestHelpers
  include Mocha::API

  def create_user_and_sign_in
    user = User.make
    user.confirm!
    sign_in user
    @user = user
  end
end
