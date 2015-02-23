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

class Api::SchedulesControllerTest < ActionController::TestCase

  setup do
    create_user_and_sign_in
    @schedule = randweeks_make
  end

  test "should show schedules" do
    get :index, :format => :json
    assert_response :success
    assert_equal [@schedule], assigns(:schedules)
  end

  test "should show schedule" do
    get :show, :id => @schedule.id, :format => :json
    assert_response :success
    assert_equal @schedule, assigns(:schedule)
  end

  test "should not show schedule from another user" do
    create_user_and_sign_in
    assert_raise { get :show, :id => @schedule.id, :format => :json }
    assert_equal nil, assigns(:schedule)
  end

end
