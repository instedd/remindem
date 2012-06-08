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

require 'test_helper'

class ReminderJobTest < ActiveSupport::TestCase

  test "message is sent on perform" do
    #setup
    pregnant = pregnant_make
    subscriber = pregnant.subscribers.find_by_offset(0)
    message = pregnant.messages.first
    
    job = ReminderJob.new(subscriber.id, pregnant.id, message.id)
    job.perform

    assert_equal 1, @messages_sent.size
    message_sent = @messages_sent[0]
    assert_equal message.text, message_sent[:body]
    assert_equal subscriber.phone_number, message_sent[:to]
    assert_equal "sms://remindem", message_sent[:from]
  end
  
  test "messages are not sent when schedule is paused" do
    #setup
    pregnant = pregnant_make
    pregnant.paused = true
    pregnant.save!
    subscriber = pregnant.subscribers.find_by_offset(0)
    message = pregnant.messages.first
    
    job = ReminderJob.new(subscriber.id, pregnant.id, message.id)
    job.perform

    assert_equal 0, @messages_sent.size
  end
  
  test "messages are not sent when schedule is deleted" do
    #setup
    pregnant = pregnant_make
    subscriber = pregnant.subscribers.find_by_offset(0)
    message = pregnant.messages.first
    pregnant.delete
    
    job = ReminderJob.new(subscriber.id, pregnant.id, message.id)
    job.perform

    assert_equal 0, @messages_sent.size
  end
end