class TourController < ApplicationController
  layout 'tour'
  helper_method :steps

  def index
    redirect_to tour_path(:start)
  end
  
  def show
    @selected_step = params[:page]
    render params[:page]
  end

  def steps
    { start: 'through any internet connection',
      schedule: 'Messages in advance',
      manage: 'as many lists as you want',
      send: 'your scheduled text messages' }
  end

end