class HomeController < ApplicationController
  def index
    add_body_class 'homepage'
  end
end