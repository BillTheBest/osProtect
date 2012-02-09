require "sys/cpu"
require 'sys/proctable'
include Sys

class DashboardController < ApplicationController
  before_filter :authenticate_user!
  before_filter :ensure_user_is_setup, only: [:index]

  def index
    # note: if current_user is an admin, groups/memberships don't matter since an admin can do anything:
    if current_user.role? :admin
      # @hot_times = Event.find_by_sql ["SELECT title FROM posts WHERE author = ? AND created > ?", author_id, start_date]
      # @hot_times = Event.find_by_sql "select sec_to_time(floor(time_to_sec(timestamp)/900)*900) as `minute`, count(*) as `cnt` from event where timestamp between '2012-10-25 00:00:00' and '2012-10-25 23:59:59' group by sec_to_time(floor(time_to_sec(timestamp)/900)*900) having `cnt` > 20"
      @hot_times = Event.find_by_sql "select sec_to_time(floor(time_to_sec(timestamp)/900)*900) as `minute`, count(*) as `cnt` from event group by sec_to_time(floor(time_to_sec(timestamp)/900)*900) having `cnt` > 20"
      @incidents = Incident.order('updated_at desc').limit(5)
      @pending_incidents = Incident.where(status: 'pending').count
      @suspicious_incidents = Incident.where(status: 'suspicious').count
      @resolved_incidents = Incident.where(status: 'resolved').count
      @priorities = SignatureDetail.select("#{SignatureDetail.table_name}.sig_priority, COUNT(#{SignatureDetail.table_name}.sig_priority) as priority_cnt").where("sig_priority IS NOT NULL").group(:sig_priority).joins(:events).order('sig_priority asc')
      @attackers = Iphdr.select("#{Iphdr.table_name}.ip_src, COUNT(#{Iphdr.table_name}.ip_src) as ipcnt").group(:sid, :ip_src).order('ipcnt desc').limit(10)
      @targets = Iphdr.select("#{Iphdr.table_name}.ip_dst, COUNT(#{Iphdr.table_name}.ip_dst) as ipcnt").group(:sid, :ip_dst).order('ipcnt desc').limit(10)
      @events = SignatureDetail.select("#{SignatureDetail.table_name}.sig_id, #{SignatureDetail.table_name}.sig_name, COUNT(#{SignatureDetail.table_name}.sig_name) as event_cnt").group(:sig_id, :sig_name).joins(:events).order('event_cnt desc').limit(10)
      @events_count = @events.length
    else
      # get current_user's sensors based on group memberships:
      sensors_for_user = current_user.sensors
      if sensors_for_user.blank?
        @events = []
        @incidents = []
        flash.now[:error] = "No sensors were found for you, perhaps you are not a member of any group. Please contact an administrator to resolve this issue."
        @events_count = 0
        return
      else
        # limit stats returned to the Sensors for this user's groups/memberships:
        groups_for_user = current_user.groups
        @hot_times = []
        @incidents = Incident.where("incidents.group_id IN (?)", groups_for_user).order('updated_at desc').limit(5)
        @pending_incidents = Incident.where(status: 'pending').count
        @suspicious_incidents = Incident.where(status: 'suspicious').count
        @resolved_incidents = Incident.where(status: 'resolved').count
        @priorities = SignatureDetail.select("#{SignatureDetail.table_name}.sig_priority, COUNT(#{SignatureDetail.table_name}.sig_priority) as priority_cnt").where("sig_priority IS NOT NULL").group(:sig_priority).joins(:events).where("event.sid IN (?)", sensors_for_user).order('sig_priority asc')
        @attackers = Iphdr.where("iphdr.sid IN (?)", sensors_for_user).select("#{Iphdr.table_name}.ip_src, COUNT(#{Iphdr.table_name}.ip_src) as ipcnt").group(:sid, :ip_src).order('ipcnt desc').limit(10)
        @targets = Iphdr.where("iphdr.sid IN (?)", sensors_for_user).select("#{Iphdr.table_name}.ip_dst, COUNT(#{Iphdr.table_name}.ip_dst) as ipcnt").group(:sid, :ip_dst).order('ipcnt desc').limit(10)
        @events = SignatureDetail.select("#{SignatureDetail.table_name}.sig_id, #{SignatureDetail.table_name}.sig_name, COUNT(#{SignatureDetail.table_name}.sig_name) as event_cnt").group(:sig_id, :sig_name).joins(:events).where("event.sid IN (?)", sensors_for_user).order('event_cnt desc').limit(10)
        @events_count = @events.length
      end
    end
  end

  def user_setup_required
    # just to show page telling user to have an admin set up their account
  end
end
