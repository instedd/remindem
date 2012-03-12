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