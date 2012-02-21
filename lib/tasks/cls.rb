require "benchmark"
require 'redis'
require 'mysql2'
# time = Benchmark.ms do
time = Benchmark.realtime do
  # assuming redis is running on the default port.
  # if not, example: redis = Redis.new(:host => "10.0.1.1", :port => 6380)
  begin
    redis = Redis.new
    # Make sure queue exists, if not create it. 
    # note: when clearing a queue with the resque web interface, 
    #       resque removes the queue, so here we just check to make sure it exists:
    puts "pdf_worker=#{redis.sismember('resque:queues', 'pdf_worker')}" # should be true
    puts "spud=#{redis.sismember('resque:queues', 'spud')}" # should be false
  rescue
    puts "can't find Redis"
  end

  # Mysql2::Client.default_query_options.merge!(as: :hash)
  Mysql2::Client.default_query_options.merge!(as: :array)
  client = Mysql2::Client.new(socket: "/tmp/mysql.sock", username: "rails", password: "rails", database: 'osprotect_dev')
  # client = Mysql2::Client.new(:socket => "/var/run/mysqld/mysqld.sock", :username => "", :password => "", :database => 'osprotect')
  # query the db for records
  results = client.query("SELECT `event`.* FROM `event` ORDER BY sid, cid asc")
  puts "results.class=#{results.class}"
  puts "results.count=#{results.count}"
  results.each do |r|
    # puts "r(#{r.class})=#{r.inspect}"
  end
  results2 = client.query("SELECT `event`.* FROM `event` ORDER BY sid, cid asc")
  puts "results.class=#{results.class}"
  puts "results.count=#{results.count}"
  results2.each do |r|
    # puts "r(#{r.class})=#{r.inspect}"
  end
end
# puts "completed in (%.1fms)" % [time]
puts "elapsed: #{time*1000} milliseconds"
# get RSS memory usage for this pid:
mem = `ps -o rss= -p #{$$}`.to_i
puts "RSS memory usage=#{mem} for $$(pid)=#{$$}"
# sleep 30

# puts "_"*100
# Benchmark.bmbm do |x|
#   x.report "Redis" do
#     redis = Redis.new
#     redis.sismember('resque:queues', 'pdf_worker')
#   end
# 
#   x.report "Mysql2" do
#     client = Mysql2::Client.new(socket: "/tmp/mysql.sock", username: "rails", password: "rails", database: 'osprotect_dev')
#     # client = Mysql2::Client.new(:socket => "/var/run/mysqld/mysqld.sock", :username => "", :password => "", :database => 'osprotect')
#     results = client.query("SELECT `event`.* FROM `event` ORDER BY sid, cid asc")
#     results.count
#   end
# end
