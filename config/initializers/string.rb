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

class String
  def with_protocol
    "sms://#{self}"
  end

  def without_protocol
    last_slash = self.rindex('/')
    if last_slash.nil?
      self
    else 
      self.from(self.rindex('/')+1)
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