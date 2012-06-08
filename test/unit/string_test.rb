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

class StringTest < ActiveSupport::TestCase
  test "to channel name replace at and dots" do
    assert_equal "lorem_plus_123_at_acme_dot_org_dot_ar", "lorem+123@acme.org.ar".to_channel_name
  end
  
  test "remove protocol" do
    assert_equal "25526", "sms://25526".without_protocol
  end
  
  test "remove protocol when there is no protocol" do
    assert_equal "35352", "35352".without_protocol
    assert_equal "", "".without_protocol    
    assert_equal nil, nil.without_protocol
  end
end
