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

class LogsControllerTest < ActionController::TestCase

  setup do
    create_user_and_sign_in
  end

  test "should get index" do
    schedule = RandomSchedule.make user: @user
    get :index, :schedule_id => schedule.id, :locale => I18n.locale
    assert_response :success
    assert_not_nil assigns(:logs)
  end
end
