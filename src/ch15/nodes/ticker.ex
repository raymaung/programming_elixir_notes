#
# Instruction:
#
# Window#1
#   iex --sname one
#   c "ticker.ex"
#   Ticker.start
#   Node.connect :"two@xxxx"  <--- after Window#2
#   Client.start
#
# Window#2
#   iex --sname two
#   Node.self  <----- get the node full name for Window#1
#   Client.start
#
defmodule Ticker do
  @interval 2000 # 2 seconds
  @name :Ticker

  def start do
    #
    # spawn the (Ticker) server process;
    # __MODULE__  equals Ticker
    # :generator  the name of action
    # [ [] ]      pass in an empty array pass parameter to :generator
    #
    pid = spawn(__MODULE__, :generator, [[], 0])

    #
    # register the PID of the server under the name :ticker
    #
    :global.register_name(@name, pid)
  end

  #
  # client who want to register to receive ticks call the "register" function
  #
  def register(client_pid) do
    #
    # client could have done the same, but calling directly be sending the :register message
    # to the server process.
    # Provinding "register" hides the registeration details to decouple the client from the server
    #
    send :global.whereis_name(@name), {:register, client_pid}
  end

  #
  # the spawned process:
  #
  def generator(clients, count) do
    receive do
      #
      # take a client PID and add to the list of clients
      #
      {:register, pid} ->
        IO.puts "registering #{inspect pid}"
        generator([pid | clients], count)
    after
      #
      # it may time out then send :tick message to all clients
      #
      @interval ->
        IO.puts "tick - #{count}"
        Enum.each clients, fn client ->
          send client, {:tick, count}
        end
        generator(clients, count + 1)
    end
  end
end

defmodule Client do
  def start do
    #
    # spawn :receiver to handle the incoming ticks and passes
    # the receiver's PID to the server as an argument to the "register" function
    #
    pid = spawn(__MODULE__, :receiver, [])
    Ticker.register(pid)
  end

  def receiver do
    receive do
      {:tick, count} ->
        IO.puts "tock in client - #{count}"
        receiver
    end
  end
end