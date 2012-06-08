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

class SubscribersControllerTest < ActionController::TestCase
  setup do
    user = users(:user1)
    user.confirm!
    sign_in user
    @randweeks = randweeks_make
    @subscriber = @randweeks.subscribers.first
  end

  test "should get index" do
    get :index, :schedule_id => @randweeks.id, :locale => I18n.locale
    assert_response :success
    assert_not_nil assigns(:subscribers)
  end

  test "should destroy subscriber" do
    assert_difference('Subscriber.count', -1) do
      delete :destroy, :id => @subscriber.to_param, :schedule_id => @randweeks.id
    end

    assert_redirected_to schedule_subscribers_path(@randweeks)
  end
end
