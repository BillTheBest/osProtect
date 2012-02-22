# note: we are doing explicit require's and include's so it is clear as to what is going on, and
#       just in case some brave soul will try to run this app in thread safe mode
require "osprotect/restrict_events_based_on_users_access"
require "osprotect/date_ranges"

class PdfWorker
  @queue = :pdf_worker
  @queue_name = "PdfWorker"

  include Osprotect::RestrictEventsBasedOnUsersAccess
  include Osprotect::DateRanges

  def self.perform(user_id, pdf_id)
    log("starting...", @queue_name)
    time = Benchmark.ms do
      pdf_max_records = APP_CONFIG[:pdf_max_records]
      pdf_details = Pdf.find(pdf_id)
      # note: these are the types of pdf's that can be created:
      #   1 - EventsReport with optional summary(pulse) page ... EventsPdf
      #   2 - IncidentsReport with description+resolution and their events ... IncidentsPdf
      #   3 - EventsSearch, directly from the events page
      report_name = 'events_report'
      if pdf_details.pdf_type == 1 || pdf_details.pdf_type == 3
        report_name = "events_report_#{pdf_details.report_id}" unless pdf_details.report_id.nil?
        report_name = "events_search_#{pdf_details.id}" if pdf_details.pdf_type == 3
        event = Event.new
        @events = event.get_events_based_on_groups_for_user(user_id)
        @event_search = EventSearch.new(pdf_details.creation_criteria)
        @events = @event_search.filter(@events)
        @events = @events.limit(pdf_max_records)
        pdf = EventsPdf.new(@events, pdf_details.creation_criteria)
      end
      path = "#{Rails.root}/shared/reports/#{user_id}"
      FileUtils.mkdir_p(path) # create path if it doesn't exist already
      filename = "#{Time.now.utc.strftime("%Y%m%d%H%M%S%N%Z")}_#{report_name}.pdf"
      pdf_file = pdf.render_file("#{path}/#{filename}")
      if pdf_file.is_a? File
        pdf_details.path_to_file = path
        pdf_details.file_name = filename
        pdf_details.save!
      end
    end
    log("completed in (%.1fms)" % [time], @queue_name)
  end

  def self.log(message, method = nil)
    now = Time.now.strftime("%Y-%m-%d %H:%M:%S")
    elapsed = "#{now} %s#%s - #{message}" % [self.name, method]
    puts elapsed
  end
end