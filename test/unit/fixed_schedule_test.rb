require 'test_helper'

class FixedScheduleTest < ActiveSupport::TestCase
  def setup
    set_current_time
    
    Nuntium.stubs(:new_from_config).returns(self)
    clear_messages
    
    @schedule = FixedSchedule.make :timescale => 'day'
    @phone_1 = 'sms://4001'
  end
  
  def teardown
    Time.unstub(:now)
  end
  
  def send_ao(message)
    @messages_sent = @messages_sent << message
  end
  
  def subscribe(phone, offset = nil)
    Subscriber.subscribe :from => phone, :body => "#{@schedule.keyword} #{offset}", :'x-remindem-user' => @schedule.user.email
  end

  def assert_no_message_sent(phone)
    assert !@messages_sent.any? { |m| m[:to] == phone }
  end
  
  def assert_message_sent(phone, text)
    assert @messages_sent.any? { |m| m[:to] == phone && m[:body] == text }
  end
  
  def clear_messages
    @messages_sent = []
  end
  
  test "subscribers should receive messages at subscription time" do
    @schedule.messages.create! :text => 'text at 1', :offset => 1
    @schedule.messages.create! :text => 'text at 3', :offset => 3
    
    time_advance 2.hours
    subscribe @phone_1
    
    time_advance 23.hours
    assert_no_message_sent @phone_1

    time_advance 2.hours
    assert_message_sent @phone_1, 'text at 1'
    clear_messages
    
    time_advance 1.day
    assert_no_message_sent @phone_1
    
    time_advance 1.day
    assert_message_sent @phone_1, 'text at 3'
  end

  test "subscribers should not receive messages far away of subscription time" do
    @schedule.messages.create! :text => 'text at 1', :offset => 1
    @schedule.messages.create! :text => 'text at 3', :offset => 3
    
    time_advance 2.hours
    subscribe @phone_1
    
    time_advance 23.hours
    assert_no_message_sent @phone_1

    time_advance 2.hours
    assert_message_sent @phone_1, 'text at 1'
    clear_messages
    
    # system is 3 hours from subscription time
    time_advance 2.hours
    assert_no_message_sent @phone_1
    
    time_advance 1.day
    assert_no_message_sent @phone_1

    time_advance 1.day
    assert_no_message_sent @phone_1

    # no matter job are pending, they should not be sent
    time_advance 1.day
    assert_no_message_sent @phone_1
    
    # until we reach near the time window.
    # in this example, exactly the subscription time
    time_advance 21.hours
    assert_message_sent @phone_1, 'text at 3'
  end
  
  test "message delivery time should use subscribers offset" do
    @schedule.messages.create! :text => 'text at 3', :offset => 3
    
    time_advance 2.hours
    subscribe @phone_1, 1
    
    time_advance 1.day
    assert_no_message_sent @phone_1

    time_advance 1.day
    assert_message_sent @phone_1, 'text at 3'
  end

  test "messages should not be sent if schedule is paused" do
    @schedule.messages.create! :text => 'text at 1', :offset => 1
  
    subscribe @phone_1
    time_advance 20.hours
    assert_no_message_sent @phone_1
    
    @schedule.paused = true
    @schedule.save!
    
    time_advance 5.hours
    assert_no_message_sent @phone_1
  end
end