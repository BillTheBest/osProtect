class PdfsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :ensure_user_is_setup

  def index
    @pdfs = current_user.pdfs.order('created_at DESC').page(params[:page]).per_page(12)
  end

  def show
    pdf = current_user.pdfs.find(params[:id])
    content_type = "application/pdf"
    if Rails.env.production?
      # note: '/private_files/' == '~/apps/osprotect/shared/reports' ... see details in /etc/nginx/nginx.conf
      # use 'head()' to let nginx handle downloading the file, which frees up rails to handle other requests:
      head(x_accel_redirect: "/private_files/#{current_user.id}/" + pdf.file_name,
           content_type: content_type,
           content_disposition: "attachment; filename=\"#{pdf.file_name}\"")
    else
      # 'send_file()' puts the burden of downloading a file on rails, which will block while doing so:
      send_file("/Users/cleesmith/Sites/osProtect_ror320/shared/reports/#{current_user.id}/" + pdf.file_name)
    end
  end

  def destroy
    pdf = current_user.pdfs.find(params[:id])
    file = pdf.path_to_file + '/' + pdf.file_name
    pdf.destroy
    begin
      FileUtils.rm(file) if File.exist?(file)
    rescue Errno::ENOENT => e
      # ignore file-not-found, let everything else pass
    end
    redirect_to pdfs_url
  end
end