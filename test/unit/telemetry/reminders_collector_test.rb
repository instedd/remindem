require 'test_helper'

class RemindersCollectorTest < ActiveSupport::TestCase

  test "counts schedules for current period" do
    3.times { RandomSchedule.make }
    5.times { CalendarBasedSchedule.make }

    period = InsteddTelemetry::Period.current

    stats = Telemetry::RemindersCollector.collect_stats(period)

    assert_equal stats, {
      "counters" => [{
        "metric" => "reminders",
        "key" => {},
        "value" => 8
      }]
    }
  end

  test "takes into account period date" do
    set_current_time
    3.times { RandomSchedule.make }
    p0 = InsteddTelemetry::Period.current

    time_advance InsteddTelemetry::Period.span
    2.times { RandomSchedule.make }
    p1 = InsteddTelemetry::Period.current

    assert_equal Telemetry::RemindersCollector.collect_stats(p0), {
      "counters" => [{
        "metric" => "reminders",
        "key" => {},
        "value" => 3
      }]
    }

    assert_equal Telemetry::RemindersCollector.collect_stats(p1), {
      "counters" => [{
        "metric" => "reminders",
        "key" => {},
        "value" => 5
      }]
    }
  end

end