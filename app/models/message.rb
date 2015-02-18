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

class Message < ActiveRecord::Base
  belongs_to :schedule

  validates_presence_of :schedule, :text
  validates_presence_of :offset,
    :if => lambda { !marked_for_destruction? && schedule.type == "FixedSchedule" },
    :message => "is required for schedules with a fixed timeline"
  validates_numericality_of :offset,
    :only_integer => true,
    :greater_than_or_equal_to => 0,
    :less_than_or_equal_to => 2147483647,
    :if => lambda { !marked_for_destruction? && schedule.type == "FixedSchedule" }

  before_destroy :alert_schedule_from_message_destroy
  after_update :alert_schedule_from_message_update
  after_create :alert_schedule_from_message_creation

  serialize :occurrence_rule

  #toDo: move this behavior to the schedule and remove the if's after merge

  def enqueue_dj_messages
    self.schedule.subscribers.each do |subscriber|
      if self.schedule.class <= FixedSchedule then
        expected_delivery_time = schedule.expected_delivery_time(self, subscriber)
      elsif self.schedule.class <= RandomSchedule then
        last_job = schedule.last_job_for(subscriber)
        if last_job.nil?
          expected_delivery_time = Time.now.utc # TODO should snap no subscription_time
        else
          expected_delivery_time = last_job.run_at + 1.send(schedule.timescale.to_sym)
        end
      end

      if Time.now <= expected_delivery_time #if in the future
        schedule.schedule_message self, subscriber, expected_delivery_time
      end
    end
  end

  def remove_dj_messages
    if self.schedule.class <= FixedSchedule then
      Delayed::Job.where(:message_id => self.id).map {|x| x.destroy}
    elsif self.schedule.class <= RandomSchedule then
      self.schedule.subscribers.each do |subscriber|
        # for RandomSchedule we find the last job, and reschedule it to be sent at the time
        # of the job we are deleting, which is the one assigned to the message that wants to
        # be deleted. This way, we ensure no blanck in the timeline are left.
        job = Delayed::Job.where(:message_id => self.id, :subscriber_id => subscriber.id).first
        next if job.nil?
        delivery_to_be_filled = job.run_at
        last_job = schedule.last_job_for(subscriber)
        last_job.run_at = delivery_to_be_filled
        last_job.save!
        job.destroy
      end
    end
  end

  def update_dj_messages
    if self.schedule.class <= FixedSchedule then
      if self.offset_changed?
        Delayed::Job.where(:message_id => self.id).each do |updatedJob|
          subscriber = Subscriber.find(updatedJob.subscriber_id)
          updatedJob.run_at = schedule.expected_delivery_time(self, subscriber)
          if Time.now < updatedJob.run_at #if in future
            updatedJob.save!
          else #if in the past
            updatedJob.destroy
          end
        end
      end
    end
  end

  def next_occurrence_date_from date
    #Returns the new occurrence date, with the same time and localization than the given date
    rule.next_suggestion(date).to_time
  end

  def rule
    @rule ||= occurrence_rule.kind_of?(String) ? IceCube::Rule.from_yaml(occurrence_rule) : occurrence_rule
    raise "Rule #{@rule} is not a valid rule object" if not @rule.kind_of?(IceCube::Rule)
    @rule
  end

  def alert_schedule_from_message_creation
    if schedule.class == CalendarBasedSchedule
      schedule.new_message_has_been_created self
    else
      enqueue_dj_messages
      schedule.log_message_created self
    end
  end

  def alert_schedule_from_message_destroy
    if schedule.class == CalendarBasedSchedule
      schedule.message_has_been_destroyed self
    else
      remove_dj_messages
      schedule.log_message_deleted self
    end
  end

  def alert_schedule_from_message_update
    if schedule.class == CalendarBasedSchedule
      schedule.message_has_been_updated self
    else
      update_dj_messages
      schedule.log_message_updated self
    end
  end

end
