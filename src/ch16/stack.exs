#
# Exercise: Compile and Run in IEX
#
# {:ok, pid} = GenServer.start_link Stack, [5, "cat", 9]
# GenServer.call pid, :pop
# > returns 5
#
defmodule Stack do
  use GenServer

  def handle_call(:pop, _from, [head | tail]) do
    { :reply, head, tail}
  end
end