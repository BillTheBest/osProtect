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

  def event_notifications
    # FIXME this needs some TLC as I have not spent any time on refactoring or optimizing!
    now_time = Time.now.utc
    one_minute_ago_time = 1.minute.ago
    if Rails.env.production?
      events = Event.includes(:signature_detail, :iphdr).select('event.sid, event.cid, event.signature, event.timestamp, signature.sig_priority, iphdr.ip_src, iphdr.ip_dst').where("timestamp >= ? AND timestamp <= ?", one_minute_ago_time, now_time)
    else
      # for testing admin:
      events = Event.includes(:signature_detail, :iphdr).select('event.sid, event.cid, event.signature, event.timestamp, signature.sig_priority, iphdr.ip_src, iphdr.ip_dst').where("timestamp >= ? AND timestamp <= ?", '2011-10-26 15:11:00', '2011-10-26 15:12:00')
      # for testing spud(non-admin):
      # events = Event.includes(:signature_detail, :iphdr).select('event.sid, event.cid, event.signature, event.timestamp, signature.sig_priority, iphdr.ip_src, iphdr.ip_dst').where("timestamp >= ? AND timestamp <= ?", '2011-11-04 00:00:00', '2011-11-08 00:02:00')
    end
    Notification.all.each do |notification|
      next if notification.disabled
      criteria = notification.notify_criteria # this was serialized as NotificationCriteria object
puts "\ncriteria=#{criteria.inspect}"
      matching_keys = []
      if notification.user.role? :admin
        users_sensors = nil # admin's see everything
      else
        users_sensors = notification.user.sensors
      end
      events.each do |event|
        next unless users_sensors.nil? || users_sensors.include?(event.sid) # sensors are an implied criteria based on user's role
        matching_keys << event.key_as_array if criteria.matches?(event)
      end
      matching_keys.uniq!
      next unless criteria.minimum_matches.zero? || (matching_keys.size >= criteria.minimum_matches)
puts "matching_keys=#{matching_keys.inspect}"
      if matching_keys.size > 0
        nr = NotificationResult.new
        nr.notification_id = notification.id
        nr.user_id = notification.user.id
        nr.notify_criteria_for_this_result = criteria
        nr.total_matches = matching_keys.size
        nr.events_timestamped_from = one_minute_ago_time
        nr.events_timestamped_to = now_time
        nr.result_ids = matching_keys
        nr.save!
      end
      # nr = NotificationResult.create!(notification_id: notification.id,
      #                                 user_id: notification.user.id,
      #                                 notify_criteria_for_this_result: criteria,
      #                                 total_matches: matching_keys.size,
      #                                 events_timestamped_from: one_minute_ago_time,
      #                                 events_timestamped_to: now_time,
      #                                 result_ids: matching_keys)
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