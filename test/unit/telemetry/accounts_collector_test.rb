require 'test_helper'

class AccountsCollectorTest < ActiveSupport::TestCase

  test "counts accounts for current period" do
    3.times { User.make }
    period = InsteddTelemetry::Period.current

    stats = Telemetry::AccountsCollector.collect_stats(period)

    assert_equal stats, {
      "counters" => [
        {
        "metric" => "accounts",
        "key" => {},
        "value" => 3
        }
      ]
    }
  end

  test "takes into account period date" do
    d0 = Time.now

    Timecop.freeze d0
    3.times { User.make }
    p0 = InsteddTelemetry::Period.current

    Timecop.freeze (d0 + InsteddTelemetry::Period.span)
    2.times { User.make }
    p1 = InsteddTelemetry::Period.current

    assert_equal Telemetry::AccountsCollector.collect_stats(p0), {
      "counters" => [{
        "metric" => "accounts",
        "key" => {},
        "value" => 3
      }]
    }

    assert_equal Telemetry::AccountsCollector.collect_stats(p1), {
      "counters" => [{
        "metric" => "accounts",
        "key" => {},
        "value" => 5
      }]
    }
  end

end