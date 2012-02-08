class NotificationCriteria
  attr_accessor :priorities, :attacker_ips, :target_ips, :minimum_matches

  def initialize
    @priorities = []
    @attacker_ips = ""
    @target_ips = ""
    @minimum_matches = 0
  end

  def matches?(event)
    matched = false
    # match any priorites
    matched = @priorities.include?(event.priority.to_s) unless @priorities.empty?
    # match attacker IP
    matched = matched && Iphdr.to_numeric(@attacker_ips) == event.iphdr.ip_src unless @attacker_ips.empty?
    # match target IPs
    matched
  end
end
