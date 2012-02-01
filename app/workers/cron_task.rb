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
      if message =~ /completed/i
        m = "elapsed=#{elapsed}\nnow=#{now}\n5.minutes.ago=#{5.minutes.ago}\ncurrent=#{Time.now.utc}"
        NotificationResult.create!(messages: m)
      end
    end
  end

  # *** put resque-scheduler tasks ***

  def event_notifications
    # FIXME this needs some TLC as I have not spent time on refactoring or optimizing!
    # alter some event timestamps so we have matches
    # 1. get notifications, which include the serialized criteria
    # 2. for each notification
    #       - use criteria to find events based on this user's access (groups/memberships)
    #       - use last_run to limit the scope of the find, instead of finding in all events
    #       - save ids or sql in notification_results, so this can be replayed/retrieve later by user
    #       - save any error messages or stats/counts
    #       - email each user a summary with a link to retrieve the events, i.e. notify them
    #    note: the above will be time consuming since it's doing each notification individually, even though
    #          the criteria to find events is similar for all users ... just different access to events, 
    #          perhaps there is a more efficient way ?

    Notification.all.each do |notification|
      matching_keys = []
      # @events = Event.includes(:sensor, :signature_detail, :iphdr).where("timestamp >= ? AND timestamp <= ?", 5.minutes.ago, Time.now.utc)
      @events = Event.includes(:sensor, :signature_detail, :iphdr).where("timestamp >= ? AND timestamp <= ?", '2011-10-26 15:10:00', '2011-10-26 15:15:00')
      @events.each do |event|
        if notification.notify_criteria.include?(event.priority.to_s)
          matching_keys << event.key
        end
        # check_box_tag "event[#{x}]", event.key, false, :id => "check_box_#{event.key_with_underscore}", :class => 'select-events' %></td>
        # event.priority
        # event.signature
        # event.source_ip_port
        # event.destination_ip_port
        # event.sensor_name
        # event.timestamp
      end
      if matching_keys.size > 0
        NotificationResult.create!(notification_id: notification.id, stats: matching_keys.size, result_ids: matching_keys)
        # note: don't pass complex objects like ActiveRecord models, just pass an id as a reference
        #       to the object(s) because the enqueue method in resque converts params to json:
        # UserMailer.event_notify(notification.user_id, notification.id).deliver
      end
    end
  end

  def some_other_task
    # logic here
  end
end