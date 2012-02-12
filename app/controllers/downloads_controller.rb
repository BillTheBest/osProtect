class DownloadsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :ensure_user_is_setup
  
  respond_to :html
  respond_to :pdf, only: [:index, :show]

  def index
    render text: 'hello from DownloadsController :-)'
  end

  def show
    # use params to get the filename and content_type
    filename = "snorby_event.pdf"
    content_type = "application/pdf"
    # use this to put the burden of downloading a file on rails, which will block while doing so:
    # send_file('/home/cleesmith/apps/osprotect/shared/reports/snorby_event.pdf')

    # use this to let nginx handle downloading the file, which frees up rails to handle the next user:
    head( :x_accel_redirect => '/private_files/' + filename,
          :content_type => content_type,
          :content_disposition => "attachment; filename=\"#{filename}\"")
Rails.logger.info "\n response.headers=#{response.headers.inspect}\n"
  end
end