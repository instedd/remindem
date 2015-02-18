module Delayed
  class Job < ActiveRecord::Base
    self.table_name = "delayed_jobs"
    attr_accessible :message_id, :subscriber_id

    belongs_to :message
    belongs_to :subscriber
  end
end
