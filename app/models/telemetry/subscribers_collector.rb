module Telemetry::SubscribersCollector

  def self.collect_stats(period)
    period_end = ActiveRecord::Base.sanitize(period.end)

    results = ActiveRecord::Base.connection.execute <<-SQL
      SELECT schedules.id, COUNT(subscribers.schedule_id)
      FROM schedules
      LEFT JOIN subscribers ON subscribers.schedule_id = schedules.id
      AND subscribers.created_at < #{period_end}
      WHERE schedules.created_at < #{period_end}
      GROUP BY schedules.id
    SQL

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
