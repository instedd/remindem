class String
  def with_protocol
    "sms://#{self}"
  end

  def without_protocol
    last_slash_index = self.rindex('/')
    if last_slash_index.nil?
      self
    else 
      self.from(last_slash_index + 1)
    end
  end
  
  def looks_as_an_int?
    Integer(self)
    true
  rescue
    false
  end
  
  def one_to_s
    case self
    when "hours", "hour"
      "an hour"
    when "days", "day"
      "a day"
    when "weeks", "week"
      "a week"
    when "months", "month"
      "a month"
    when "years", "year"
      "a year"
    else
      nil
    end
  end
  
  def to_channel_name
    self.gsub(/@/, '_at_').gsub(/\./, '_dot_').gsub(/\+/, '_plus_')
  end
end

class NilClass
  def without_protocol
    self
  end
end