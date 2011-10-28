class HelpController < ApplicationController
	
  def faq
    respond_to do |format|
      format.html # index.html.erb
    end
  end

end