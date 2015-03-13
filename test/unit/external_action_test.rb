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

class ExternalActionTest < ActiveSupport::TestCase

  test "should replace blanks for Verboice structure" do
    mapping = {"channel"=>"callcentric", "phone_number"=>"subscriber_phone", "vars"=>{}}
    action = ExternalAction.make
    subscriber = Subscriber.make schedule_id: action.schedule_id, phone_number: 'sms://9991000'
    assert_equal({"channel"=>"callcentric", "phone_number"=>"9991000", "vars"=>{}}, action.data(mapping, subscriber))
  end

  test "should replace blanks for ResourceMap structure" do
    mapping = {"properties"=>{"id"=>"subscriber_phone", "name"=>"subscriber_phone", "lat"=>"days_since_registration", "long"=>"days_since_registration", "layers"=>{"652"=>{"_seen_heroku_4_"=>"", "_master_site_id_heroku_4_"=>""}, "653"=>{"id"=>"subscriber_phone", "type"=>"", "location"=>"", "date"=>""}}}}
    action = ExternalAction.make
    subscriber = Subscriber.make schedule_id: action.schedule_id, phone_number: 'sms://+9991000'
    assert_equal({"properties"=>{"id"=>"9991000", "name"=>"9991000", "lat"=>subscriber.days_since_registration, "long"=>subscriber.days_since_registration, "layers"=>{"652"=>{"_seen_heroku_4_"=>"", "_master_site_id_heroku_4_"=>""}, "653"=>{"id"=>"9991000", "type"=>"", "location"=>"", "date"=>""}}}}, action.data(mapping, subscriber))
  end

end
