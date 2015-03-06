require 'csv'

class BulkUpload

  attr_accessor :subscriptions, :user, :time, :unsubscribe

  def initialize(user, opts={})
    @user = user
    @time = opts[:time]
    @unsubscribe = opts[:unsubscribe]
    @subscriptions ||= []

    load_from_csv(opts[:file]) if opts[:file]
  end

  def load_from_csv(file)
    index = 1
    CSV.foreach(file.path, headers: false) do |row|
      subscriptions << SubscriptionIntent.new(
        owner: user,
        index: index,
        unique: unsubscribe,
        time: time,
        subscriber: row[0],
        keyword: row[1],
        offset: row[2])
      index += 1
    end
    self
  end

  def valid?
    subscriptions.all?(&:valid?)
  end

  def process!
    subscriptions.each do |s|
      s.create!
    end
  end

end
