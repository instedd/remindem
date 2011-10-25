class TourController < ApplicationController
  
  def show
    render params[:page]
  end
end