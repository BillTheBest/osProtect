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
      # if message =~ /completed/i
      #   m = "elapsed=#{elapsed}\nnow=#{now}\n5.minutes.ago=#{5.minutes.ago}\ncurrent=#{Time.now.utc}"
      #   NotificationResult.create!(messages: m)
      # end
    end
  end

  # *** put resque-scheduler tasks ***

  def event_notifications
    # FIXME this needs some TLC as I have not spent time on refactoring nor optimizing!

    # general process flow:
    # 1. get events from now back to 1 minute ago (or however often this job runs)
    # 2. for each notification
    #       - use criteria to find events based on this user's access (groups/memberships)
    #       - save ids or sql in notification_results, so this can be replayed/retrieve later by user
    #       - save any error messages or stats/counts
    #       - email each user a summary with a link to retrieve the events, i.e. notify them, we may
    #         want to consider only sending out emails every 10-15 minutes instead of for each job run
    #
    # attributes:
    #   event.key
    #   event.timestamp.to_f (epoch seconds)
    #   event.sid = sensor.id
    #   event.priority ...via... event.signature
    #   event.iphdr.ip_source      ...or... event.source_ip_port (this causes additional db finds)
    #   event.iphdr.ip_destination ...or... event.destination_ip_port (this causes additional db finds)

    now_time = Time.now.utc
    one_minute_ago_time = 1.minute.ago
    if Rails.env.production?
      events = Event.includes(:signature_detail, :iphdr).select('event.sid, event.cid, event.signature, event.timestamp, signature.sig_priority, iphdr.ip_src, iphdr.ip_dst').where("timestamp >= ? AND timestamp <= ?", one_minute_ago_time, now_time)
    else
      # for testing admin:
      events = Event.includes(:signature_detail, :iphdr).select('event.sid, event.cid, event.signature, event.timestamp, signature.sig_priority, iphdr.ip_src, iphdr.ip_dst').where("timestamp >= ? AND timestamp <= ?", '2011-10-26 15:11:00', '2011-10-26 15:12:00')
      # for testing spud(non-admin):
      # events = Event.includes(:signature_detail, :iphdr).select('event.sid, event.cid, event.signature, event.timestamp, signature.sig_priority, iphdr.ip_src, iphdr.ip_dst').where("timestamp >= ? AND timestamp <= ?", '2011-11-08 00:00:01', '2011-11-08 00:02:00')
    end
    Notification.all.each do |notification|
      next if notification.disabled
      matching_keys = []
      if notification.user.role? :admin
        # if the user who owns this notification is an admin then groups/memberships don't matter:
        users_sensors = nil
      else
        # otherwise use the sensors(based on group memberships) for the user who owns this notification:
        users_sensors = notification.user.sensors
      end
      events.each do |event|
        # does this event match all criteria (users_sensors are implied criteria):
        next unless users_sensors.nil? || users_sensors.include?(event.sid)
        matching_keys << event.key_as_array if notification.notify_criteria.include?(event.priority.to_s)
      end
      matching_keys.uniq!
      nr = NotificationResult.create!(notification_id: notification.id,
                                      user_id: notification.user.id,
                                      total_matches: matching_keys.size,
                                      events_timestamped_from: one_minute_ago_time,
                                      events_timestamped_to: now_time,
                                      result_ids: matching_keys) if matching_keys.size > 0
    end
  end

  def batched_email_notifications
    Notification.all.each do |notification|
      next if notification.disabled
      next if notification.notification_results.where(email_sent: false).count < 1
      # note: don't pass complex objects like ActiveRecord models, just pass id's as references
      #       to the object(s) because the enqueue method in resque converts params to json:
      UserMailer.batched_email_notifications(notification.id).deliver
    end
  end
end