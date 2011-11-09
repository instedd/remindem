class TourController < InsteddRails::TourController

  def steps
    { start: 'through any internet connection',
      schedule: 'Messages in advance',
      manage: 'as many lists as you want',
      send: 'your scheduled text messages' }
  end

end