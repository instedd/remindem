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
    set_current_time
    schedule = RandomSchedule.make
    p0 = InsteddTelemetry::Period.current
    schedule.subscribers.make

    time_advance InsteddTelemetry::Period.span
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

  test "counts schedules with 0 subscribers" do
    period = InsteddTelemetry::Period.current

    schedule_1 = RandomSchedule.make created_at: period.end - 5.days
    schedule_2 = CalendarBasedSchedule.make created_at: period.end - 1.day
    schedule_3 = RandomSchedule.make created_at: period.end + 1.day

    Subscriber.make schedule: schedule_2, created_at: period.end + 1.day
    Subscriber.make schedule: schedule_3, created_at: period.end + 3.days

    stats = Telemetry::SubscribersCollector.collect_stats(period)
    counters = stats['counters']

    assert_equal 2, counters.size

    schedule_1_stat = counters.find{|x| x['key']['schedule_id'] == schedule_1.id}
    schedule_2_stat = counters.find{|x| x['key']['schedule_id'] == schedule_2.id}

    assert_equal schedule_1_stat, {
      "metric" => "subscribers",
      "key" => { "schedule_id" => schedule_1.id },
      "value" => 0
    }

    assert_equal schedule_2_stat, {
      "metric" => "subscribers",
      "key" => { "schedule_id" => schedule_2.id },
      "value" => 0
    }
  end
end
