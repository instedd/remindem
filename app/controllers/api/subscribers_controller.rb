class Api::SubscribersController < ApiController

  before_filter :load_schedule


  # GET /api/reminders/1/subscribers.json
  # GET /api/reminders/1/subscribers.xml
  def index
    @subscribers = @schedule.subscribers

    respond_to do |format|
      format.xml   { render :xml => @subscribers }
      format.json  { render :json => @subscribers }
    end
  end

  # GET /api/reminders/1/subscribers/1.xml
  # GET /api/reminders/1/subscribers/1.json
  def show
    @subscriber = @schedule.subscribers.find(params[:id])
    raise ActiveRecord::RecordNotFound if @subscriber.nil?
    respond_to do |format|
      format.json { render :json => @subscriber }
      format.xml  { render :xml => @subscriber }
    end
  end

  # GET /api/reminders/1/subscribers/find.xml?phone_number=sms://12345678
  # GET /api/reminders/1/subscribers/find.json?phone_number=sms://12345678
  def find
    @subscriber = @schedule.subscribers.where(phone_number: params[:phone_number].ensure_protocol).first
    raise ActiveRecord::RecordNotFound if @subscriber.nil?
    respond_to do |format|
      format.xml  { render :xml => @subscriber }
      format.json { render :json => @subscriber }
    end
  end

  # POST /api/reminders/1/subscribers.json
  def create
    @intent = SubscriptionIntent.new owner: current_user,
      subscriber: params[:phone_number],
      schedule: @schedule,
      offset: params[:offset],
      unique: false

    if @intent.valid?
      @subscriber = @intent.find_or_create
      render :json => @subscriber
    else
      render :json => @intent.errors, :status => :unprocessable_entity
    end
  end

  private

  def load_schedule
    @schedule = current_user.schedules.find(params[:schedule_id])
  end

end
