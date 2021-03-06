class SubscriptionIntent
  include ActiveModel::Validations

  attr_accessor :user, :index, :time, :subscriber, :keyword, :offset, :unique, :created

  validates :phone_number, length: { minimum: 8 }
  validates :offset, numericality: true

  validate :keyword do
    errors.add(:keyword, _("#{keyword} not found or schedule not specified")) unless schedule
  end

  validate :time do
    errors.add(:time, _("Invalid hour specified")) if subscribed_at.blank?
    errors.add(:time, _("Time of day cannot be 00:00 hs")) if subscribed_at && subscribed_at.hour == 0
  end

  def initialize(attrs={})
    @user = attrs[:owner]
    @index = attrs[:index]
    @subscriber = attrs[:subscriber]
    @schedule = attrs[:schedule]
    @keyword = attrs[:keyword]
    @offset = attrs[:offset].try(:to_i) || 0
    @unique = attrs[:unique]
    @time = attrs[:time]
  end

  def phone_number
    subscriber.gsub(/[^\d]/, '').with_protocol
  end

  def subscribed_at
    @subscribed_at ||= time.blank? ? Time.now.utc : Time.now.utc.change(hour: time.to_i, minute: 0, second: 0)
  rescue
    nil
  end

  def schedule
    @schedule ||= user.schedules.find_by_keyword(keyword.strip)
  end

  def action_description
    if created
      "Subscribed %{phone_number} to reminder %{reminder} (%{keyword}) with offset %{offset} on time %{time}" \
        % {phone_number: phone_number, reminder: schedule.title, keyword: schedule.keyword, offset: offset, time: subscribed_at.to_s(:time)}
    else
      "Subscriber %{phone_number} in reminder %{reminder} (%{keyword}) was already subscribed" \
        % {phone_number: phone_number, reminder: schedule.title, keyword: schedule.keyword}
    end
  end

  def create!
    return false if already_exists?
    do_subscribe
  end

  def find_or_create
    already_exists? || do_subscribe
  end

  def unsubscribe_all!
    Subscriber.where(phone_number: phone_number, schedule_id: user.schedule_ids).destroy_all
  end

  def already_exists?
    Subscriber.find_by_phone_number_and_schedule_id(phone_number, schedule.id)
  end

  private

  def do_subscribe
    unsubscribe_all! if unique
    subscriber_object = Subscriber.create!(
                  :phone_number => phone_number,
                  :offset => offset,
                  :schedule => schedule,
                  :subscribed_at => subscribed_at)

    schedule.subscribe subscriber_object
    self.created = true
    subscriber_object
  end

end
