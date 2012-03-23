# note: we are doing explicit require's and include's so it is clear as to what is going on, and
#       just in case some brave soul will try to run this app in thread safe mode
require "osprotect/date_ranges"
require "osprotect/pulse_top_tens"

class DashboardController < ApplicationController
  before_filter :authenticate_user!
  before_filter :ensure_user_is_setup, only: [:index]

  include Osprotect::DateRanges
  include Osprotect::PulseTopTens

  def index
    @title = "Pulse"
    params[:range] = 'today' if params[:range].blank?
    take_pulse(current_user, params[:range])
  end

  def user_setup_required
    # this allows to show a page telling user to have an admin set up their account
  end
end
