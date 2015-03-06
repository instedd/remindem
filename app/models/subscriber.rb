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

class Subscriber < ActiveRecord::Base
  belongs_to :schedule

  validates_presence_of :phone_number, :subscribed_at, :offset, :schedule_id
  validates_numericality_of :offset, :only_integer => true

  def self.modify_subscription_according_to params
    keyword, offset = params[:body].split
    sender_phone_number = params[:from]

    user = User.find_by_email params[:'x-remindem-user']
    return reply(invalid_author(keyword), :to => sender_phone_number, :'x-remindem-user' => params[:'x-remindem-user']) unless user

    unless Schedule.is_opt_out_keyword? keyword
      schedule = user.schedules.find_by_keyword keyword
      return [user.build_message(sender_phone_number, no_schedule_message(keyword))] unless schedule

      return [user.build_message(sender_phone_number, already_registered_message(keyword))] if self.find_by_phone_number_and_schedule_id sender_phone_number, schedule.id

      return [user.build_message(sender_phone_number, invalid_offset_message(params[:body], offset))] unless offset.nil? || offset.looks_as_an_int?

      new_subscriber = create! :phone_number => sender_phone_number,
                                          :offset => offset ? offset : 0,
                                          :schedule => schedule,
                                          :subscribed_at => Time.now.utc
      schedule.subscribe new_subscriber
    else
      schedule = user.schedules.find_by_keyword offset
      if schedule
        subscriber = find_by_phone_number_and_schedule_id sender_phone_number, schedule
        if subscriber
          subscriber.destroy
          [user.build_message(sender_phone_number, goodbye_message(schedule))]
        else
          [user.build_message(sender_phone_number,unkwnown_subscriber_message(offset))]
        end
      else
        subscribers = find_all_by_phone_number sender_phone_number
        if subscribers.size == 1
          subscribers.first.destroy
          [user.build_message(sender_phone_number, goodbye_message(subscribers.first.schedule))]
        else
          keywords = (subscribers.collect { |a_subscriber| a_subscriber.schedule.keyword}).join(', ')
          [user.build_message(sender_phone_number, please_specify_keyword_message(keywords))]
        end
      end
    end
  end

  def reference_time
    self.subscribed_at - self.offset.send(self.schedule.timescale.to_sym)
  end

  def can_receive_message
    # iif we are +/-2 hours from subscription time
    (Time.now.utc.seconds_since_midnight - self.subscribed_at.seconds_since_midnight).abs.seconds < 2.hours
  end

  def days_since_registration
    (Date.today - subscribed_at.to_date).to_i
  end

  def self.no_schedule_message keyword
    "Sorry, there's no reminder program named #{keyword} :(."
  end

  def self.invalid_offset_message body, offset
    "Sorry, we couldn't understand your message. You sent #{body}, but we expected #{offset} to be a number."
  end

  def self.invalid_author keyword
    "Sorry, there was a problem finding #{keyword} owner."
  end

  def self.please_specify_keyword_message keywords
    "You are subscribed to: #{keywords}. Please specify the reminder you want to unsubscribe: 'off keyword'."
  end

  def self.unkwnown_subscriber_message keyword
    "Sorry, you are not subscribed to reminder program named #{keyword} :(."
  end

  def self.goodbye_message schedule
    "You have successfully unsubscribed from the \"#{schedule.title}\" Reminder. To subscribe again send \"#{schedule.keyword}\" to this number"
  end

  def self.already_registered_message keyword
    "Sorry, you are already subscribed to reminder program named #{keyword}. To unsubscribe please send 'stop #{keyword}'."
  end

  def for_api
    self.as_json.merge("phone_number" => phone_number.without_protocol.gsub(/^\+/, ''))
  end

  private

  def self.reply msg, options
    [{:from => "remindem".with_protocol, :body => msg, :to => options[:to], :'x-remindem-user' => options[:'x-remindem-user']}]
  end
end
