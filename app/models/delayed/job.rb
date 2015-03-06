module Delayed
  class Job < ActiveRecord::Base
    self.table_name = "delayed_jobs"
    attr_accessible :message_id, :subscriber_id

    belongs_to :message
    belongs_to :subscriber

    scope :of_kind, lambda { |klazz| all.select {|dj| dj.handler_kind_of?(klazz) } }

    def handler_kind_of?(klazz)
      YAML.load(handler).kind_of?(klazz)
    end
  end
end
