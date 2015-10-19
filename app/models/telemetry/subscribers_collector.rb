module Telemetry::SubscribersCollector

  def self.collect_stats(period)
    query = Subscriber.select(["schedule_id", "count(*)"])
                      .where("created_at < ?", period.end)
                      .group("schedule_id")
                      .to_sql

    results = ActiveRecord::Base.connection.execute query

    {
      "counters" => results.map { |schedule_id, count|
        {
          "metric" => "subscribers",
          "key"    => { "schedule_id" => schedule_id },
          "value"  => count,
        }
      }
    }
  end


end