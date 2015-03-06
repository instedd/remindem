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

class Api::SubscribersControllerTest < ActionController::TestCase

  setup do
    create_user_and_sign_in
    @randweeks = randweeks_make
    @subscriber = @randweeks.subscribers.first
  end

  test "should show subscribers" do
    get :index, :schedule_id => @randweeks.id, :format => :json
    assert_response :success
    assert_equal @randweeks.subscribers.sort, assigns(:subscribers).sort
  end

  test "should show subscriber" do
    get :show, :id => @subscriber.id, :schedule_id => @randweeks.id, :format => :json
    assert_response :success
    assert_equal @subscriber, assigns(:subscriber)
  end

  test "should remove protocol from subscriber phone in show" do
    get :show, :id => @subscriber.id, :schedule_id => @randweeks.id, :format => :json
    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal @subscriber.phone_number.without_protocol, json_response['phone_number']
  end

  test "should not show subscriber from another user" do
    create_user_and_sign_in
    assert_raise { get :show, :id => @subscriber.id, :schedule_id => @randweeks.id, :format => :json }
    assert_equal nil, assigns(:subscriber)
  end

  test "should find subscriber by phone" do
    get :find, :phone_number => @subscriber.phone_number, :schedule_id => @randweeks.id, :format => :json
    assert_response :success
    assert_equal @subscriber, assigns(:subscriber)
  end

  test "should find subscriber by phone without specifying protocol" do
    get :find, :phone_number => @subscriber.phone_number.without_protocol, :schedule_id => @randweeks.id, :format => :json
    assert_response :success
    assert_equal @subscriber, assigns(:subscriber)
  end

  test "should not find subscriber from another user" do
    create_user_and_sign_in
    assert_raise { get :find, :phone_number => @subscriber.phone_number, :schedule_id => @randweeks.id, :format => :json }
    assert_equal nil, assigns(:subscriber)
  end

  test "should create new subscriber" do
    assert_difference('Subscriber.count', 1) do
      post :create, :phone_number => 'sms://9999999', :schedule_id => @randweeks.id, :format => :json, :offset => 1
    end
    assert_response :success
    assert_equal Subscriber.last, assigns(:subscriber)
  end

  test "should not recreate existing subscriber" do
    assert_difference('Subscriber.count', 0) do
      post :create, :phone_number => @subscriber.phone_number, :schedule_id => @randweeks.id, :format => :json, :offset => 1
    end
    assert_response :success
    assert_equal @subscriber, assigns(:subscriber)
  end

  test "should not create existing subscriber for a schedule from another user" do
    create_user_and_sign_in
    assert_difference('Subscriber.count', 0) do
      assert_raise do
        post :create, :phone_number => @subscriber.phone_number, :schedule_id => @randweeks.id, :format => :json, :offset => 1
      end
    end
    assert_equal nil, assigns(:subscriber)
  end

end
