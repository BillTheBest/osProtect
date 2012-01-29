class Ability
  include CanCan::Ability

  def initialize(user)
    if user.role? :admin
      can     :manage, :all
    else
      can     :update,  User, :id => user.id
      can     :read,    [Sensor, SensorName]
      can     :manage,  Notification
      cannot  :manage,  [Group, Membership]
    end
  end
end
