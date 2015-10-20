require 'test_helper'
include InsteddTelemetry

class AccountLifespanTrackingTest < ActiveSupport::TestCase

  setup do
    Timecop.freeze(Time.now)
    @user = User.make
  end

  test "it tracks user creation" do
    timespan = Timespan.find_by_bucket(:account_lifespan)
    verify_lifespan(@user.created_at)
  end

 test "it tracks user settings update" do
   updates_lifespan do
     @user.touch
     @user.save
   end
 end

 test "it tracks schedule CRUD" do
   updates_lifespan { @schedule = RandomSchedule.make user: @user }
   updates_lifespan { @schedule.touch; @schedule.save }
   updates_lifespan { @schedule.destroy }
 end

 test "it tracks schedule's messages CRUD" do
   @schedule = RandomSchedule.make user: @user
   updates_lifespan { @message = Message.make schedule: @schedule}
   updates_lifespan { @message.touch; @message.save }
   updates_lifespan { @message.destroy }
 end

 test "it tracks identity CRUD" do
   updates_lifespan { @identity = @user.identities.make }
   updates_lifespan { @identity.touch; @identity.save }
   updates_lifespan { @identity.destroy }
 end

 test "it tracks channel CRUD" do
   Channel.any_instance.stubs(:remove_channel_from_nuntium)

   updates_lifespan { @channel = Channel.create user: @user }
   updates_lifespan { @channel.touch; @channel.save }
   updates_lifespan { @channel.destroy }
 end

 def updates_lifespan(&block)
   Timecop.freeze(Time.now + 3.seconds)
   block.call
   verify_lifespan(Time.now)
 end

 def verify_lifespan(last_activity_time)
   timespan = Timespan.find_by_bucket(:account_lifespan)
   assert_equal timespan.since.to_i, @user.created_at.to_i
   assert_equal timespan.until.to_i, last_activity_time.to_i
 end

end