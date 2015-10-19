module Telemetry::RemindersCollector

  def self.collect_stats(period)
    {
      "counters" => [{
        "metric"  => "reminders",
        "key"   => {},
        "value" => Schedule.where('created_at < ?', period.end).count
      }]
    }
  end


end