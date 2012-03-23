# create at least one admin user:
u = User.create!(username: 'admin', email: 'alexandros.clone@gmail.com', password: 'cl0nesys01', password_confirmation: 'cl0nesys01')
# create admins group and a default membership for admin user:
g = Group.create!(name: 'admins', user_ids: u.id)
# see the 'after_save' callback in the Group model for how this user is assigned the admin role

# create a fake event:
# e = Event.create!(sid: 1, cid: 9999, signature: 2, timestamp: "2012-03-21 09:40:00")
# i = Iphdr.create!(sid: 1, cid: 9999, ip_src: 1385596426, ip_dst: 3232238467, ip_ver: 4, ip_proto: 6)
# t = Tcphdr.create!(sid: 1, cid: 9999, tcp_sport: 53197, tcp_dport: 22, tcp_flags: 24)
