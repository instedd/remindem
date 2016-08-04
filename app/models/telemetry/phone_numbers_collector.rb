module Telemetry::PhoneNumbersCollector
  def self.collect_stats(period)
    {"counters" => schedules_counters(period).concat(global_counters(period))}
  end

  def self.schedules_counters(period)
    subscribers = Subscriber.where("created_at < ?", period.end).select("distinct phone_number, schedule_id")
    schedule_data = {}

    subscribers.each do |subscriber|
      schedule_id = subscriber.schedule_id
      number = subscriber.phone_number.without_protocol
      country_code = InsteddTelemetry::Util.country_code number
      if country_code.present?
        schedule_data[schedule_id] ||= Hash.new(0)
        schedule_data[schedule_id][country_code] += 1
      end
    end

    counters = schedule_data.inject [] do |r, (application_id, numbers_by_country_code)|
      r.concat(numbers_by_country_code.map do |country_code, count|
        {
          "metric" => "unique_phone_numbers_by_project_and_country",
          "key"    => { "project_id" => application_id, "country_code" => country_code },
          "value"  => count
        }
      end)
    end

    counters
  end

  def self.global_counters(period)
    query = Subscriber.select("distinct phone_number")
                      .where("created_at < ?", period.end)
                      .group("phone_number")
                      .to_sql
    results = ActiveRecord::Base.connection.execute query

    counts = Hash.new(0)

    results.each do |number, count|
      country_code = InsteddTelemetry::Util.country_code(number.without_protocol) rescue nil
      if country_code
        counts[country_code] += 1
      end
    end

    counters = counts.map do |code, count|
      {
        "metric" => "unique_phone_numbers_by_country",
        "key"    => { "country_code" => code },
        "value"  => count
      }
    end

    counters
  end
end
