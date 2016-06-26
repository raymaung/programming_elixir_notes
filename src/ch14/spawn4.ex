defmodule Spawn4 do
  def greet do
    receive do
      {sender, msg} ->
        send sender, {:ok, "Hello #{msg}"}
        #
        # Wait itself to receive more messages
        #
        greet
    end
  end
end

# Here's a client
pid = spawn(Spawn4, :greet, [])
send pid, {self, "World!"}

receive do
  {:ok, message} -> IO.puts message
end

send pid, {self, "Kermit!"}
receive do
  {:ok, message} -> IO.puts message
  #
  # Error after waiting for half seconds
  #
  after 500 ->
    IO.puts "The greeter has gone away"
end