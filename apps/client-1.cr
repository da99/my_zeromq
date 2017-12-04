
require "zeromq"

ID = ARGV[0]
macro fail!(str)
  STDERR.puts "!!! Failed: {{str.id}}"
  STDERR.puts "!!! Exit 2"
  exit 2
end # === macro fail!


# Simple client
ZMQ::Context.create(ZMQ::REQ) do |ctx, (socket)|
  # client = ctx.socket(ZMQ::REQ)
  socket.connect("ipc://my_media_proc.ipc") || break
  socket.set_socket_option(ZMQ::LINGER, 0)
  poller = ZMQ::Poller.new
  poller.register(socket, ZMQ::POLLIN)

  %w(asi c99 keiichi).each { |question|
    socket.send_string("#{ID} #{question}", ZMQ::DONTWAIT)
    fail!("Timeout") unless poller.poll(500)
    answer = socket.receive_string ZMQ::DONTWAIT
    sleep ID.to_i
    if answer.empty?
      puts "=== FAILED: #{question}: EMPTY ANSWER"
      break
    end
    pieces = answer.split(" <|> ")
    key = pieces.shift
    id = pieces.shift
    answer = pieces.join(" <|> ")
    if key != question
      puts "=== MATCH FAIL: #{question} != #{key} : #{answer}"
      break
    else
      puts "=== #{ID == id} PASS: #{question}:\t#{answer.inspect}"
    end
  }
end # === Context.new

puts "=== DONE: client-1 #{ID}"


