# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

# create at least one admin user:
u = User.create!(username: 'molly', email: 'cleesmith2006@gmail.com', password: 'molly1', password_confirmation: 'molly1')
User.create!(username: 'spud', email: 'spud@spud.com', password: 'spudder', password_confirmation: 'spudder')
# create admins group and a default membership for admin user:
g = Group.create!(name: 'admins', user_ids: u.id)
# see the 'after_save' callback in the Group model for how this user is assigned the admin role
