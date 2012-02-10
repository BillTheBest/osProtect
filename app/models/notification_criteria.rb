class NotificationCriteria
  attr_accessor :priorities, :attacker_ips, :target_ips, :minimum_matches

  def initialize
    @priorities = []
    @attacker_ips = ""
    @target_ips = ""
    @minimum_matches = 0
  end

  def matches?(event)
    # if no criteria is present then this notification matches anything/everything:
    return true if @priorities.empty? && @attacker_ips.empty? && @target_ips.empty?
    matched = false
    if @priorities.empty?
      matched = true # no priorities were specifed so any will match
    else
      matched = @priorities.include?(event.priority.to_s)
    end
    matched = matched && Iphdr.to_numeric(@attacker_ips) == event.iphdr.ip_src unless @attacker_ips.empty?
    matched = matched && Iphdr.to_numeric(@target_ips)   == event.iphdr.ip_dst unless @target_ips.empty?
    matched
  end

  def to_s
    self.minimum_matches.to_s +
    self.priorities.sort.to_s +
    self.attacker_ips +
    self.target_ips
  end
end
