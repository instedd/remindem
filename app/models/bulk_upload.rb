require 'csv'

class BulkUpload

  attr_accessor :subscriptions, :user

  def initialize(user)
    @user = user
    @subscriptions ||= []
  end

  def self.from_csv(file, user)
    upload = self.new(user)
    index = 0
    CSV.foreach(file.path, headers: false) do |row|
      upload.subscriptions << SubscriptionIntent.new(
        owner: user,
        index: index,
        subscriber: row[0],
        keyword: row[1],
        offset: row[2])
      index += 1
    end
    upload
  end

  def valid?
    subscriptions.all?(&:valid?)
  end

  def process!
    subscriptions.each do |s|
      s.create!
    end
  end

  class SubscriptionIntent
    include ActiveModel::Validations

    attr_accessor :user, :index, :subscriber, :keyword, :offset, :unique, :created

    validates :phone_number, length: { minimum: 5}
    validates :offset, numericality: true

    validate :keyword do |r|
      errors.add(:keyword, _("Reminder with keyword #{keyword} not found")) unless schedule
    end

    def initialize(attrs={})
      @user = attrs[:owner]
      @index = attrs[:index]
      @subscriber = attrs[:subscriber]
      @keyword = attrs[:keyword]
      @offset = attrs[:offset].try(:to_i) || 0
      @unique = attrs[:unique]
    end

    def valid?
      phone_number.size > 5
    end

    def phone_number
      subscriber.gsub(/[^\d]/, '')
    end

    def schedule
      @schedule ||= user.schedules.find_by_keyword(keyword.strip)
    end

    def action_description
      if created
        "Subscribe %{phone_number} to reminder %{reminder} (%{keyword}) with offset %{offset}" \
          % {phone_number: phone_number, reminder: schedule.title, keyword: schedule.keyword, offset: offset}
      else
        "Subscriber %{phone_number} in reminder %{reminder} (%{keyword}) was already subscribed" \
          % {phone_number: phone_number, reminder: schedule.title, keyword: schedule.keyword}
      end
    end

    def create!
      return false if already_exists?

      unsubscribe_all! if unique

      schedule.subscribe Subscriber.create!(
                        :phone_number => phone_number,
                        :offset => offset,
                        :schedule => schedule,
                        :subscribed_at => Time.now.utc)

      created = true
    end

    def unsubscribe_all!
      Subscriber.where(phone_number: phone_number, schedule_id: user.schedule_ids).destroy_all
    end

    def already_exists?
      Subscriber.find_by_phone_number_and_schedule_id(phone_number, schedule.id)
    end

  end

end
