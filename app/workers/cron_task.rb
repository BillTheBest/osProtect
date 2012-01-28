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
      puts "#{now} %s#%s - #{message}" % [self.name, method]
    end
  end

  # tasks:

  def event_notifications
    # 1. get notifications, which include a serialized criteria
    # 2. for each notification
    #       - use criteria to find events based on this user's access (groups/memberships)
    #       - use last_run to limit the scope of the find, instead of finding in all events
    #       - save ids or sql in notification_results, so this can be replayed/retrieve later by user
    #       - save any error messages or stats/counts
    #       - email each user a summary with a link to retrieve the events, i.e. notify them
    #
    #    note: the above will be time consuming since it's doing each notification individually, even though
    #          the criteria to find events is similar for all users ... just different access to events, 
    #          perhaps there is a more efficient way ?

    NotificationResult.create!(messages: 'hello!')
  end

  def some_other_task
    # logic here
  end
end