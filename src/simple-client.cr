
require "zeromq"
require "json"


module Alclonia::Demon
 # Simple client
  context = ZMQ::Context.new
  client = context.socket(ZMQ::REQ)
  client.connect("tcp://127.0.0.1:5555")
  payload_out = {"idx_name": "real_estates", "cmd": "search", "filter": "neighborhood:Laureles"}.to_json
  msg_out = ZMQ::Message.new( payload_out )
  client.send_message(msg_out)
  rcvd_msgs = client.receive_messages
  puts "received msg has #{rcvd_msgs.size} items"
  obj = rcvd_msgs.map { |msg|
   puts msg.to_s
   JSON.parse(msg.to_s.strip) }
  puts "#{obj.size}"
end
