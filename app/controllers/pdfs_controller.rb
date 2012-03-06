class PdfsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :ensure_user_is_setup

  def index
    @pdfs = current_user.pdfs.order('created_at DESC').page(params[:page]).per_page(APP_CONFIG[:per_page])
  end

  def show
    pdf = current_user.pdfs.find(params[:id])
    report = pdf.report
    report = Report.new if report.blank? # some pdf's aren't based on a report
    content_type = "application/pdf"
    path = ['d', 'w', 'm'].include?(report.auto_run_at) ? "#{current_user.id}/#{report.auto_run_at}" : "#{current_user.id}"
    if Rails.env.production? && APP_CONFIG[:web_server] == 'nginx'
      # note: '/private_files/' == '~/apps/osprotect/shared/reports' ... see details in /etc/nginx/nginx.conf
      # use 'head()' to let nginx handle downloading the file, which frees up rails to handle other requests:
      head(x_accel_redirect: "/private_files/#{path}/" + pdf.file_name,
           content_type: content_type,
           content_disposition: "attachment; filename=\"#{pdf.file_name}\"")
    else
      # 'send_file()' puts the burden of downloading a file on rails, which will block while doing so:
      send_file("#{Rails.root}/shared/reports/#{path}/" + pdf.file_name)
      # send_file("/Users/cleesmith/Sites/osProtect_ror320/shared/reports/#{path}/" + pdf.file_name)
    end
  end

  def destroy
    pdf = current_user.pdfs.find(params[:id])
    if pdf.blank?
      redirect_to pdfs_url
      return
    end
    file = pdf.path_to_file + '/' + pdf.file_name unless pdf.path_to_file.blank? || pdf.file_name.blank?
    pdf.destroy
    unless file.blank?
      begin
        FileUtils.rm(file) if File.exist?(file)
      rescue Errno::ENOENT => e
        # ignore file-not-found, let everything else pass
      end
    end
    redirect_to pdfs_url
  end
end