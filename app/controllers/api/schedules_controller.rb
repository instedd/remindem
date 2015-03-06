class Api::SchedulesController < ApiController

  # GET /schedules.xml
  # GET /schedules.json
  def index
    @schedules = current_user.schedules
    respond_to do |format|
      format.xml   { render :xml => @schedules }
      format.json  { render :json => @schedules }
    end
  end

  # GET /schedules/1.xml
  # GET /schedules/1.json
  def show
    @schedule = current_user.schedules.find(params[:id])
    respond_to do |format|
      format.xml   { render :xml => @schedule }
      format.json  { render :json => @schedule }
    end
  end

end
