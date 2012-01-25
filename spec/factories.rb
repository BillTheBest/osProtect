FactoryGirl.define do
  factory :user do
    sequence(:username) { |n| "foo#{n}" }
    sequence(:email) { |n| "foo#{n}@example.com" }
    password "secret"
  end

  factory :sensor do
    sequence(:sid) { |n| n }
    hostname "localhost"
    sequence(:last_cid) { |n| n }
  end

  factory :event do
    # sid 1
    sequence(:sid) { |n| n }
    sequence(:cid) { |n| n }
    sequence(:timestamp) { Time.now.to_s }
    sequence(:signature) { |n| n }
    # note due to composite keys these must be set after creating an event:
    # signature_detail { |si| si.association(:signature_detail) }
    # sensor { |s| s.association(:sensor) }
    # iphdr { |i| i.association(:iphdr) }
  end

  factory :iphdr do
    sequence(:sid) { |n| n }
    sequence(:cid) { |n| n }
    sequence(:ip_src) { |n| n }
    sequence(:ip_dst) { |n| n }
    sequence(:ip_ver) { |n| n }
    sequence(:ip_hlen) { |n| n }
    sequence(:ip_tos) { |n| n }
    sequence(:ip_len) { |n| n }
    sequence(:ip_id) { |n| n }
    sequence(:ip_flags) { |n| n }
    sequence(:ip_off) { |n| n }
    sequence(:ip_ttl) { |n| n }
    sequence(:ip_proto) { |n| n }
    sequence(:ip_csum) { |n| n }
  end

  factory :tcphdr do
    sequence(:sid) { |n| n }
    sequence(:cid) { |n| n }
    sequence(:tcp_sport) { |n| n }
    sequence(:tcp_dport) { |n| n }
    sequence(:tcp_seq) { |n| n }
    sequence(:tcp_ack) { |n| n }
    sequence(:tcp_off) { |n| n }
    sequence(:tcp_res) { |n| n }
    sequence(:tcp_flags) { |n| n }
    sequence(:tcp_win) { |n| n }
    sequence(:tcp_csum) { |n| n }
    sequence(:tcp_urp) { |n| n }
  end

  factory :signature_detail do
    sequence(:sig_id) { |n| n }
    sig_name 'bad stuff'
    sequence(:sig_class_id) { |n| n }
  end
end
