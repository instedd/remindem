require 'test_helper'

class PhoneNumbersCollectorTest < ActiveSupport::TestCase

  setup do
    set_current_time
    @schedule = RandomSchedule.make
  end

  test "counts numbers by country code for current period" do
    (1..3).each { |i| @schedule.subscribers.make phone_number: "sms://54 11 4444 555#{i}" }
    (1..4).each { |i| @schedule.subscribers.make phone_number: "sms://855 23 686 036#{i}" }

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
    @schedule.subscribers.make phone_number: "sms://54 11 4444 5555"
    @schedule.subscribers.make phone_number: "sms://123"

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
    (1..2).each { |i| @schedule.subscribers.make phone_number: "sms://54 11 4444 555#{i}" }
    p0 = InsteddTelemetry::Period.current

    time_advance InsteddTelemetry::Period.span
    (3..9).each { |i| @schedule.subscribers.make phone_number: "sms://54 11 4444 555#{i}" }
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
