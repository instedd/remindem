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

class Schedule < ActiveRecord::Base

  validates_presence_of :keyword, :user_id, :welcome_message, :type, :title
  validates_presence_of :timescale, :unless => Proc.new {|schedule| schedule.type == "CalendarBasedSchedule"}
  validates_uniqueness_of :keyword
  validates_length_of :keyword, :maximum => 15
  validates_format_of :keyword, :with => /^[^ ]+$/, :message => "must not include spaces"
  validates_length_of :title, :maximum => 60

  before_destroy :notify_deletion_to_subscribers
  before_update :log_changes

  after_initialize { self.notifySubscribers = true }
  attr_accessor :notifySubscribers

  belongs_to :user

  validates_presence_of :user

  has_many :messages, :dependent => :destroy
  has_many :subscribers, :dependent => :destroy
  has_many :logs, :dependent => :destroy

  accepts_nested_attributes_for :messages, :allow_destroy => true
  validates_associated :messages
  before_validation :initialize_messages

  scope :paused, where(paused: true)


  def keyword_is_not_opt_out_keyword
    if keyword && self.class.is_opt_out_keyword?(keyword)
      errors.add(:keyword, "Must not be \"#{self.class.opt_out_keyword}\" as it will be used for subscribers to unsubscribe.")
    end
  end

  validate :keyword_is_not_opt_out_keyword

  def self.inherited(child)
    # force all subclass to have :schedule as model name
    child.instance_eval do
      def model_name
        Schedule.model_name
      end
    end
    super
  end

  def subscribe subscriber
    generate_reminders_for subscriber
    log_new_subscription_of subscriber.phone_number
    notify_subscription_to_hub subscriber
    welcome_message_for subscriber.phone_number
  end

  def generate_reminders_for recipient
    messages = self.reminders

    messages.each_with_index do |message, index|
      self.enqueue_reminder message, index, recipient
    end
  end

  def welcome_message_for phone_number
    [build_message(phone_number, welcome_message)]
  end

  def self.time_scale_options
    [[_('Minutes'), 'minutes'], [_('Hours'), 'hours'], [_('Days'), 'days'], [_('Weeks'), 'weeks'], [_('Months'), 'months'], [_('Years'), 'years']]
  end

  def build_message to, body
    self.user.build_message to, body
  end

  def send_or_reschedule message, subscriber
    if !paused?
      if subscriber.can_receive_message
        send_message subscriber.phone_number, message.text
      else
        #TODO-LOW build a better estimate for when to reschedule, although thanks to the
        # timewindow restriction, this will be pushed many times until it is able to go out
        try_to_send_it_at = Time.now.utc + 1.hour
        schedule_message message, subscriber, try_to_send_it_at
        create_warning_log_described_by "The message '#{message.text}' was delayed due to #{subscriber.phone_number.without_protocol} localtime"
      end
    else
      create_warning_log_described_by "The message '#{message.text}' was not sent to #{subscriber.phone_number.without_protocol} since schedule is paused"
    end
  end

  def schedule_message message, subscriber, send_at
    Delayed::Job.enqueue ReminderJob.new(subscriber.id, self.id, message.id),
      :message_id => message.id, :subscriber_id => subscriber.id, :run_at => send_at
  end

  def last_job_for subscriber
    Delayed::Job.order('run_at DESC').where(:subscriber_id => subscriber.id).first
  end

  def send_message to, body
    nuntium = Nuntium.new_from_config
    message = self.build_message to, body
    nuntium.send_ao message
    log_message_sent body, to
  end

  def log_message_sent body, recipient_number
    create_information_log_described_by (_("The message '%{body}' was sent to %{recipient}") % {body: body, recipient: recipient_number.without_protocol})
  end

  def log_new_subscription_of recipient_number
    create_information_log_described_by (_("New subscriber: %{subscriber}") % {subscriber: recipient_number.without_protocol})
  end

  def create_warning_log_described_by description
    Log.create! :schedule => self, :severity => :warning, :description => description
  end

  def create_information_log_described_by description
    Log.create! :schedule => self, :severity => :information, :description => description
  end

  def log_message_updated message
    create_information_log_described_by _("Message updated: %{message}") % {message: message.text}
  end

  def log_message_deleted message
    create_information_log_described_by _("Message deleted: %{message}") % {message: message.text}
  end

  def log_message_created message
    create_information_log_described_by _("Message created: %{message}") % {message: message.text}
  end

  def initialize_messages
    messages.each { |m| m.schedule = self }
  end

  def notify_deletion_to_subscribers
    if notifySubscribers
      subscribers.each do |subscriber|
        self.send_message(subscriber.phone_number,
          (_("The schedule %{keyword} has been deleted. You will no longer receive messages from this schedule.") % {keyword: self.keyword}))
      end
    end
  end

  def log_changes
    log_if_welcome_message_changed
    log_if_paused_or_resumed
  end

  def log_if_welcome_message_changed
    if welcome_message_changed?
      log_welcome_message_updated
    end
  end

   def log_welcome_message_updated
    create_information_log_described_by (_("Welcome message has been updated: %{message}") % {message: welcome_message})
  end

  def log_if_paused_or_resumed
    if paused_changed?
      if paused?
        log_schedule_paused
      else
        log_schedule_resumed
      end
    end
  end

  def log_schedule_paused
    create_information_log_described_by _("Schedule paused")
  end

  def log_schedule_resumed
    create_information_log_described_by _("Schedule resumed")
  end

  def mode_in_words
    raise NotImplementedError, 'Subclasses must redefine this message'
  end

  def self.is_opt_out_keyword? keyword
    keyword.upcase == opt_out_keyword.upcase
  end

  def self.opt_out_keyword
    'stop'
  end

  def notify_subscription_to_hub(subscriber)
    return if not HubClient.current.enabled?
    Delayed::Job.enqueue SubscribedEvent.new(subscriber.id), subscriber_id: subscriber.id
  end

  def duration
    raise NotImplementedError, 'Subclasses must redefine this message'
  end

end
