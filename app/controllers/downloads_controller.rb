class DownloadsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :ensure_user_is_setup

  def show
    # id: report id
    # use :id to get the filename and content_type
    filename = "snorby_event.pdf"
    content_type = "application/pdf"
    if Rails.env.production?
      # note: '/private_files/' is aliased to '/home/cleesmith/apps/osprotect/shared/reports'
      #       see details in /etc/nginx/nginx.conf
      # use 'head()' to let nginx handle downloading the file, which frees up rails to handle the next user:
      head(x_accel_redirect: '/private_files/' + filename,
           content_type: content_type,
           content_disposition: "attachment; filename=\"#{filename}\"")
    else
      # 'send_file()' puts the burden of downloading a file on rails, which will block while doing so:
      send_file('/Users/cleesmith/Sites/osProtect_ror320/shared/reports/' + filename)
    end
  end
end