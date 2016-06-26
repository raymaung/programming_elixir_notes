defmodule Spawn2 do
  def greet do
    receive do
      {sender, msg} ->
        send sender, {:ok, "Hello #{msg}"}
    end
  end
end

# Here's a client
pid = spawn(Spawn2, :greet, [])
send pid, {self, "World!"}

receive do
  {:ok, message} -> IO.puts message
end

#
# Will hang here because ;greet can handle only a single message
#
send pid, {self, "Kermit!"}
receive do
  {:ok, message} -> IO.puts message
end