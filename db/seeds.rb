# create at least one admin user:
u = User.create!(username: 'admin', email: 'change_me@gmail.com', password: 'whatever', password_confirmation: 'whatever')
# create admins group and a default membership for admin user:
g = Group.create!(name: 'admins', user_ids: u.id)
# see the 'after_save' callback in the Group model for how this user is assigned the admin role
