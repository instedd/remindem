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

class LogTest < ActiveSupport::TestCase
  test "validate presence of required fields in Log" do
    log = Log.new
    log.save

    assert log.invalid?
    assert !log.errors[:severity].blank?, "Severity must be present for all logs"
    assert !log.errors[:description].blank?, "Description must be present for all logs"
    assert !log.errors[:schedule].blank?, "Every log belongs to a schedule"
  end
  
  test "symbols are recovered from database as symbols" do
    Log.make :severity => :information
    assert_equal :information, Log.first.severity
  end
end
