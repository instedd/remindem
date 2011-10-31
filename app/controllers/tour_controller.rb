class TourController < ApplicationController
  def index
    redirect_to tour_path(:start)
  end
  
  def show
    render params[:page]
  end
end