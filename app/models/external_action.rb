class ExternalAction < Message
  serialize :external_actions, Hash

  def description
    external_actions['path']
  end

  def run schedule, subscriber

  end

  def execute subscriber
    HubClient.current.invoke external_actions['path'], data(external_actions['mapping'], subscriber)
  end

  def data(mapping, subscriber)
    Hash[mapping.map do |key, value|
      if value === Hash
        Hash[data(value, subscriber)]
      else value === :subscriber_phone_number
        [key, subscriber.phone_number]
      else
        [key, value]
      end
    end]
  end

end
