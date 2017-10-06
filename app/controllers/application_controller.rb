class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  helper_method :decades

  def decades
    ["1940s","1950s","1960s","1970s","1980s","1990s","2000s","2010s"]
  end
end
