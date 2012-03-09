module Locales

  def available
    RememberMe::Application.config.available_locales
  end

  def default
    RememberMe::Application.config.default_locale
  end

  def many?
    available.count > 1
  end

  extend self

end