class Ability
  include CanCan::Ability

  def initialize(user)
    if user.role? :admin
      can :manage, :all
    else
      # i.e. user.role == :user
      can :update, User, :id => user.id
      can :read, Event, ["event.sid IN (?)", user.sensors] do |event|
        user.sensors.include? event.sid
      end
      can :read, [Sensor, SensorName]
      can :manage, Incident, :group => { :id => user.groups }
      can :manage, Notification
      # note: put cannot's last so they take effect no matter what is above:
      cannot :manage, [Group, Membership]
    end
  end
end
