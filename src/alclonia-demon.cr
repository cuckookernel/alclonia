# TODO: Write documentation for `Alclonia::Demon`
# TODO: Implement Numeric Index

require "zeromq"
require "json"

require "./core"
require "./collection_cfg"
require "./collection"
require "./util"

module AlcloniaDemon

  VERSION = "0.1.0"
  DATA_DIR = "/home/teo/_data"

end



def start_demon
  cfg = CollectionCfg.from_file( AlcloniaDemon::DATA_DIR + "/real_estates.cfg.json" )

  coll = Collection.new( cfg )

  coll.populate_from_file( AlcloniaDemon::DATA_DIR + "/real_estates.json" )

  context = ZMQ::Context.new
  server = context.socket(ZMQ::REP)
  server.bind("tcp://127.0.0.1:5555")

  loop do
      msg_str_in = server.receive_string
      resps : Array(String) = [] of String
      elapsed = Time.measure do
        msg_in = Msg.from_json( msg_str_in )
        cmd = msg_in["cmd"]

        if cmd == "search"
          filter_str = msg_in["filter"]
          #result_items = coll.run_filter( filter_str )
          result_items = coll.items.values.first(188)
          # server.send_string({"msg": result_items.size.to_s + " found"}.to_json)
          resps = result_items.map { |it| it.rec.to_json + " " }
          # resps = result_items.map { |it| it.raw.to_json }
          puts "result_items has #{result_items.size}  resp has #{resps.size}"
        else
          resps = [ {"err": "Unrecognized cmd: " + cmd}.to_json ]
        end
      end # elapsed
      puts "elapsed: #{elapsed.to_f} now sending response message"
      server.send_messages( resps.map { |s| ZMQ::Message.new(s) } )
  end

end

start_demon