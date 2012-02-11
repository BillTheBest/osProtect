class ReportsController < ApplicationController
  # before_filter :authenticate_user!
  # before_filter :ensure_user_is_setup
  # 
  # respond_to :html
  # respond_to :pdf, only: [:index, :show]

  def index
    render text: 'hello from Reports :-)'
  end

  def show
    # use params to get the filename and content_type
    filename = "snorby_event.pdf"
    content_type = "application/pdf"
    head( :x_accel_redirect => '/pdf_reports/' + filename,
          :content_type => content_type,
          :content_disposition => "attachment; filename=\"#{filename}\"")
  end
end