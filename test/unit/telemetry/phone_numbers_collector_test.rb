require 'test_helper'

class PhoneNumbersCollectorTest < ActiveSupport::TestCase

  setup { @schedule = RandomSchedule.make }

  test "counts numbers by country code for current period" do
    (1..3).each { |i| @schedule.subscribers.make phone_number: "54 11 4444 555#{i}" }
    (1..4).each { |i| @schedule.subscribers.make phone_number: "855 23 686 036#{i}" }

    period = InsteddTelemetry::Period.current

    stats = Telemetry::PhoneNumbersCollector.collect_stats(period)

    assert_equal stats, {
      "counters" => [
        {
        "metric" => "phone_numbers",
        "key" => { "country_code" => "54" },
        "value" => 3
        },
        {
        "metric" => "phone_numbers",
        "key" => { "country_code" => "855" },
        "value" => 4
        }
      ]
    }
  end

  test "it ignores undetermined country codes" do
    @schedule.subscribers.make phone_number: "54 11 4444 5555"
    @schedule.subscribers.make phone_number: "123"

    period = InsteddTelemetry::Period.current
    stats = Telemetry::PhoneNumbersCollector.collect_stats(period)

    assert_equal stats, {
      "counters" => [
        {
        "metric" => "phone_numbers",
        "key" => { "country_code" => "54" },
        "value" => 1
        }
      ]
    }
  end

  test "takes into account period date" do
    d0 = Date.today

    Timecop.freeze d0
    (1..2).each { |i| @schedule.subscribers.make phone_number: "54 11 4444 555#{i}" }
    p0 = InsteddTelemetry::Period.current

    Timecop.freeze (d0 + 1.week)
    (3..9).each { |i| @schedule.subscribers.make phone_number: "54 11 4444 555#{i}" }
    p1 = InsteddTelemetry::Period.current

    assert_equal Telemetry::PhoneNumbersCollector.collect_stats(p0), {
      "counters" => [
        {
        "metric" => "phone_numbers",
        "key" => { "country_code" => "54" },
        "value" => 2
        }
      ]
    }

    assert_equal Telemetry::PhoneNumbersCollector.collect_stats(p1), {
      "counters" => [
        {
        "metric" => "phone_numbers",
        "key" => { "country_code" => "54" },
        "value" => 9
        }
      ]
    }
  end

end