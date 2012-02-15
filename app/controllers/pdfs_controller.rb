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
      # note: '/private_files/' is aliased to '/home/cleesmith/apps/osprotect/shared/reports'
      #       see details in /etc/nginx/nginx.conf
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
    pdf.destroy
    # FIXME if record delete then don't forget to delete the actual pdf file ?
    # def flush_deletes #:nodoc:
    #   @queued_for_delete.each do |path|
    #     begin
    #       log("deleting #{path}")
    #       FileUtils.rm(path) if File.exist?(path)
    #     rescue Errno::ENOENT => e
    #       # ignore file-not-found, let everything else pass
    #     end
    #     begin
    #       while(true)
    #         path = File.dirname(path)
    #         FileUtils.rmdir(path)
    #         break if File.exists?(path) # Ruby 1.9.2 does not raise if the removal failed.
    #       end
    #     rescue Errno::EEXIST, Errno::ENOTEMPTY, Errno::ENOENT, Errno::EINVAL, Errno::ENOTDIR, Errno::EACCES
    #       # Stop trying to remove parent directories
    #     rescue SystemCallError => e
    #       log("There was an unexpected error while deleting directories: #{e.class}")
    #       # Ignore it
    #     end
    #   end
    #   @queued_for_delete = []
    # end
    redirect_to pdfs_url
  end
end