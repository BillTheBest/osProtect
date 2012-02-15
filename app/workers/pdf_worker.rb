class PdfWorker
  @queue = :pdf_worker
  @queue_name = "PdfWorker"

  def self.perform(user_id, report_criteria_id)
    log("starting...", @queue_name)
    time = Benchmark.ms do
      # get_events_based_on_groups_for_current_user
      # pdf = EventsPdf.new(@events, params[:q])
      @events=Event.limit(10).all
      # @events=@events+Event.all
      pdf = EventsPdf.new(@events, nil)
      # can't send PDF to user, as we are in the background, so we save it as a file:
      path = "#{Rails.root}/shared/reports/#{user_id}"
      FileUtils.mkdir_p(path) # create path if doesn't exist already
      filename = "#{Time.now.utc.strftime("%Y%m%d%H%M%S%N%Z")}_events_report.pdf"
      pdf.render_file("#{path}/#{filename}")
      # FIXME ensure PDF file was created ?
      # record PDF details:
      pdf_details = Pdf.new
      pdf_details.user_id = user_id
      # pdf_details.report_id = report_id
      pdf_details.path_to_file = path
      pdf_details.file_name = filename
      pdf_details.save!
    end
    log("completed in (%.1fms)" % [time], @queue_name)
  end

  def self.log(message, method = nil)
    now = Time.now.strftime("%Y-%m-%d %H:%M:%S")
    elapsed = "#{now} %s#%s - #{message}" % [self.name, method]
    puts elapsed
  end
end