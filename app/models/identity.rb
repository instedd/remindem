class Identity < ActiveRecord::Base
  attr_accessible :provider, :token, :user_id

  belongs_to :user

  after_save    { user.telemetry_track_activity }
  after_destroy { user.telemetry_track_activity }
end
