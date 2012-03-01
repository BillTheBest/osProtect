class CronTask

  class << self
    def perform(method)
      with_logging method do
        self.new.send(method)
      end
    end

    def with_logging(method, &block)
      log("starting...", method)
      time = Benchmark.ms do
        yield block
      end
      log("completed in (%.1fms)" % [time], method)
    end

    def log(message, method = nil)
      now = Time.now.strftime("%Y-%m-%d %H:%M:%S")
      elapsed = "#{now} %s#%s - #{message}" % [self.name, method]
      puts elapsed
    end
  end

  # the following methods are resque-scheduler tasks:

  def batched_email_notifications
    Notification.all.each do |notification|
      next if notification.disabled
      next if notification.notification_results.where(email_sent: false).count < 1
      # note: don't pass complex objects like ActiveRecord models, just pass id's as references
      #       to the object(s) because the enqueue method in resque converts params to json:
      UserBackgroundMailer.batched_email_notifications(notification.id).deliver
    end
  end

  def event_notifications
    # FIXME this needs some TLC as I have not spent any time on refactoring nor optimizing!
    #
    # assumptions:
    #   1. there is less than 1 minute to process everything
    #   2. there are only a few hundred events/alerts per day per sensor (well tuned)
    #   3. there is a way to mass insert events into an incident
    #
    now_time = Time.now.utc
    one_minute_ago_time = 1.minute.ago
    temp_event = Event.new
    Notification.all.each do |notification|
      next if notification.disabled
      criteria = notification.notify_criteria
      matching_keys = []
      sensors = nil # admin's can see all sensors
      sensors = notification.user.sensors unless notification.user.role? :admin
      if Rails.env.production?
        @events = temp_event.get_events_based_on_groups_for_user(notification.user.id)
        @events = @events.where("timestamp >= ? AND timestamp <= ?", one_minute_ago_time, now_time)
      else
        @events = Event.includes(:sensor, :signature_detail, :iphdr, :tcphdr, :udphdr).where("timestamp >= ? AND timestamp <= ?", '2011-10-26 15:09:00', '2011-10-26 15:12:00')
        # @events = Event.includes(:sensor, :signature_detail, :iphdr, :tcphdr, :udphdr).where("timestamp >= ? AND timestamp <= ?", '2011-11-04 00:00:00', '2011-11-08 00:02:00')
      end
      @event_search = EventSearch.new(criteria)
      @events = @event_search.filter(@events) # sets: @start_time and @end_time
      next if @events.count < 1 # no events matched for this notification so go to the next one
      if @events.count > APP_CONFIG[:max_events_that_can_be_copied_to_incidents_for_each_notification]
        @events = @events.limit(APP_CONFIG[:max_events_that_can_be_copied_to_incidents_for_each_notification])
      end
      @events.each do |event|
        next unless sensors.nil? || sensors.include?(event.sid)
        matching_keys << event.key_as_array
      end
      matching_keys.uniq!
      next unless @event_search.minimum_matches.zero? || (matching_keys.size >= @event_search.minimum_matches)
      if matching_keys.size > 0
        ActiveRecord::Base.transaction do
          nr = NotificationResult.new
          nr.notification_id = notification.id
          nr.user_id = notification.user.id
          nr.notify_criteria_for_this_result = criteria
          nr.total_matches = matching_keys.size
          nr.events_timestamped_from = one_minute_ago_time
          nr.events_timestamped_to = now_time
          nr.result_ids = matching_keys
          nr.save!
          incident_name = "Events for Notification ##{notification.id}"
          incident_description = "Matching Events during #{one_minute_ago_time} - #{now_time}."
          add_events_to_incident(incident_name, incident_description, notification.user, @events)
        end
      end
    end
  end

  def daily_report_emailed_as_pdf
    return unless APP_CONFIG[:can_daily_report]
    Report.where(auto_run_at: 'd', run_status: true).each do |report|
      users = User.all
users = User.where(id: 1)
      users.each do |user|
        # UserBackgroundMailer.events_cron_report(user.id, report.id).deliver if report.report_type == 1
        UserBackgroundMailer.incidents_cron_report(user.id, report.id).deliver if report.report_type == 2
      end
    end
  end

  def weekly_report_emailed_as_pdf
    return unless APP_CONFIG[:can_weekly_report]
    Report.where(auto_run_at: 'w', run_status: true).each do |report|
      users = User.all
      users.each do |user|
        UserBackgroundMailer.events_cron_report(user.id, report.id).deliver if report.report_type == 1
      end
    end
  end

  def monthly_report_emailed_as_pdf
    return unless APP_CONFIG[:can_monthly_report]
    Report.where(auto_run_at: 'm', run_status: true).each do |report|
      users = User.all
      users.each do |user|
        UserBackgroundMailer.events_cron_report(user.id, report.id).deliver if report.report_type == 1
      end
    end
  end

  private

  def add_events_to_incident(name, description, user, events)
    return nil if events.blank? || user.blank?
    incident = Incident.create(user_id: user.id, group_id: user.groups.first.id, incident_name: name, incident_description: description)
    events.each do |event|
      incident_events_attributes = IncidentEvent.set_attributes(event)
      incident.incident_events.build(incident_events_attributes)
    end
    incident.save(validate: false)
    incident || nil
  end

end