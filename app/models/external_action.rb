class ExternalAction < Message
  serialize :external_actions, Hash

  def description
    external_actions['path']
  end

  def run(schedule, subscriber)
    schedule.send_or_execute self, subscriber
  end

  def execute subscriber
    HubClient.current.invoke external_actions['path'], data(external_actions['mapping'], subscriber)
  end

  def data(mapping, subscriber)
    Hash[mapping.map do |key, value|
      if value === Hash
        Hash[data(value, subscriber)]
      elsif value === :subscriber_phone_number
        [key, subscriber.phone_number]
      elsif value === :days_since_registration
        [key, subscriber.days_since_registration]
      else
        [key, value]
      end
    end]
  end

end
