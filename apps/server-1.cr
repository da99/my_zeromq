
require "zeromq"
require "shell_out"

# Simple server
ZMQ::Context.create(ZMQ::REP) { |ctx, (server)|
  server.bind("ipc://my_media_proc.ipc")

  loop do
    pieces = server.receive_string.split
    id = pieces.first
    question = pieces.last
    # puts "--- QUESTION: #{question.inspect}"
    case question
    when "QUIT"
      server.send_string("quitting", ZMQ::DONTWAIT)
      break
    else
      server.send_string("#{question} <|> #{id} <|> #{shell_out("/apps/my_media/bin/my_media", ["title", question]).strip}", ZMQ::DONTWAIT)
    end
  end
  puts "--- closing server"
  # server.close
}
puts "--- DONE: Context terminated: server-1"

# server.bind("tcp://127.0.0.1:5555")

# loop do
  # case question
  # when "QUIT"
  #   server.send_string("QUIT")
  #   puts "--- CLOSING: server in server-1"
  #   server.close
  #   # break
  # else
  #   server.send_string("Got it")
  # end
# # end

# at_exit {
  # context.terminate
# }


