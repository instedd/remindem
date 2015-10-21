require 'test_helper'

class SubscribersCollectorTest < ActiveSupport::TestCase

  test "counts subscribers by reminder for current period" do
    r1 = RandomSchedule.make
    r2 = CalendarBasedSchedule.make

    3.times { r1.subscribers.make }
    4.times { r2.subscribers.make }

    period = InsteddTelemetry::Period.current
    stats = Telemetry::SubscribersCollector.collect_stats(period)

    assert_equal stats, {
      "counters" => [
        {
        "metric" => "subscribers",
        "key" => { "schedule_id" => r1.id },
        "value" => 3
        },{
        "metric" => "subscribers",
        "key" => { "schedule_id" => r2.id },
        "value" => 4
      }]
    }
  end

  test "takes into account period date" do
    schedule = RandomSchedule.make
    d0 = Time.now

    Timecop.freeze d0
    p0 = InsteddTelemetry::Period.current
    schedule.subscribers.make

    Timecop.freeze (d0 + InsteddTelemetry::Period.span)
    p1 = InsteddTelemetry::Period.current
    schedule.subscribers.make


    assert_equal Telemetry::SubscribersCollector.collect_stats(p0), {
      "counters" => [
        {
          "metric" => "subscribers",
          "key" => { "schedule_id" => schedule.id },
          "value" => 1
        }
      ]
    }

    assert_equal Telemetry::SubscribersCollector.collect_stats(p1), {
      "counters" => [
        {
          "metric" => "subscribers",
          "key" => { "schedule_id" => schedule.id },
          "value" => 2
        }
      ]
    }
  end

end