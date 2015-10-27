module Telemetry::PhoneNumbersCollector

  def self.collect_stats(period)
    query = Subscriber.select(["phone_number, count(*)"])
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

    {
      "counters" => counts.map { |code, count|
        {
          "metric" => "phone_numbers",
          "key"    => { "country_code" => code },
          "value"  => count
        }
      }
    }
  end


end
