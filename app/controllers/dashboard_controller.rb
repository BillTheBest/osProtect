# require "#{Rails.root}/lib/osprotect/date_ranges"
require "osprotect/date_ranges"

class DashboardController < ApplicationController
  before_filter :authenticate_user!
  before_filter :ensure_user_is_setup, only: [:index]

  include Osprotect::DateRanges

  def index
    params[:range] = 'today' if params[:range].blank?
    set_time_range(params[:range])
    # note: if current_user is an admin, groups/memberships don't matter since an admin can do anything:
    if current_user.role? :admin
      # every 15 minutes (900 seconds = 15  * 60):
      @hot_times = Event.find_by_sql ["SELECT SEC_TO_TIME(FLOOR(TIME_TO_SEC(timestamp)/900)*900) AS `minute`, count(*) as `cnt` from event where timestamp BETWEEN ? AND ? GROUP BY SEC_TO_TIME(FLOOR(TIME_TO_SEC(timestamp)/900)*900) HAVING `cnt` > 10", @start_time, @end_time]
      @priorities = SignatureDetail.select("#{SignatureDetail.table_name}.sig_priority, COUNT(#{SignatureDetail.table_name}.sig_priority) as priority_cnt").where("sig_priority IS NOT NULL").group(:sig_priority).joins(:events).order('sig_priority asc')
      @priorities = @priorities.where('timestamp between ? and ?', @start_time, @end_time)
      @attackers = Iphdr.select("#{Iphdr.table_name}.ip_src, COUNT(#{Iphdr.table_name}.ip_src) AS ipcnt").group('iphdr.sid', 'iphdr.ip_src')
      @attackers = @attackers.joins(:events).where('timestamp between ? and ?', @start_time, @end_time).limit(10)
      @targets = Iphdr.select("#{Iphdr.table_name}.ip_dst, COUNT(#{Iphdr.table_name}.ip_dst) as ipcnt").group('iphdr.sid', 'iphdr.ip_dst')
      @targets = @targets.joins(:events).where('timestamp between ? and ?', @start_time, @end_time).limit(10)
      @events = SignatureDetail.select("#{SignatureDetail.table_name}.sig_id, #{SignatureDetail.table_name}.sig_name, COUNT(#{SignatureDetail.table_name}.sig_name) as event_cnt").group(:sig_id, :sig_name).joins(:events).order('event_cnt desc').limit(10)
      @events = @events.where('timestamp between ? and ?', @start_time, @end_time)
      @events_count = @events.length
      # @incidents = Incident.order('updated_at desc').limit(5)
      # @pending_incidents = Incident.where(status: 'pending').count
      # @suspicious_incidents = Incident.where(status: 'suspicious').count
      # @resolved_incidents = Incident.where(status: 'resolved').count
    else
      # get current_user's Sensors based on group memberships:
      sensors_for_user = current_user.sensors
      if sensors_for_user.blank?
        @events = []
        @incidents = []
        flash.now[:error] = "No sensors were found for you, perhaps you are not a member of any group. Please contact an administrator to resolve this issue."
        @events_count = 0
        return
      else
        # every 15 minutes (900 seconds = 15  * 60):
        @hot_times = Event.find_by_sql ["SELECT SEC_TO_TIME(FLOOR(TIME_TO_SEC(timestamp)/900)*900) AS `minute`, count(*) as `cnt` from event where event.sid IN (?) AND timestamp BETWEEN ? AND ? GROUP BY SEC_TO_TIME(FLOOR(TIME_TO_SEC(timestamp)/900)*900) HAVING `cnt` > 10", sensors_for_user, @start_time, @end_time]
        @priorities = SignatureDetail.select("#{SignatureDetail.table_name}.sig_priority, COUNT(#{SignatureDetail.table_name}.sig_priority) as priority_cnt").where("sig_priority IS NOT NULL").group(:sig_priority).joins(:events).where("event.sid IN (?)", sensors_for_user).order('sig_priority asc')
        @priorities = @priorities.where('timestamp between ? and ?', @start_time, @end_time)
        @attackers = Iphdr.where("iphdr.sid IN (?)", sensors_for_user).select("#{Iphdr.table_name}.ip_src, COUNT(#{Iphdr.table_name}.ip_src) as ipcnt").group('iphdr.sid', 'iphdr.ip_src')
        @attackers = @attackers.joins(:events).where('timestamp between ? and ?', @start_time, @end_time).limit(10)
        @targets = Iphdr.where("iphdr.sid IN (?)", sensors_for_user).select("#{Iphdr.table_name}.ip_dst, COUNT(#{Iphdr.table_name}.ip_dst) as ipcnt").group('iphdr.sid', 'iphdr.ip_dst')
        @targets = @targets.joins(:events).where('timestamp between ? and ?', @start_time, @end_time).limit(10)
        @events = SignatureDetail.select("#{SignatureDetail.table_name}.sig_id, #{SignatureDetail.table_name}.sig_name, COUNT(#{SignatureDetail.table_name}.sig_name) as event_cnt").group(:sig_id, :sig_name).joins(:events).where("event.sid IN (?)", sensors_for_user)
        @events = @events.where('timestamp between ? and ?', @start_time, @end_time).order('event_cnt desc').limit(10)
        @events_count = @events.length
        # limit stats returned to the Sensors for this user's groups/memberships:
        # groups_for_user = current_user.groups
        # @incidents = Incident.where("incidents.group_id IN (?)", groups_for_user).order('updated_at desc').limit(5)
        # @pending_incidents = Incident.where(status: 'pending').count
        # @suspicious_incidents = Incident.where(status: 'suspicious').count
        # @resolved_incidents = Incident.where(status: 'resolved').count
      end
    end
  end

  def user_setup_required
    # this allows to show a page telling user to have an admin set up their account
  end
end
