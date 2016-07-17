#
# Exercise: Compile and Run in IEX
#
# {:ok, pid} = GenServer.start_link Stack, [5, "cat", 9]
# GenServer.call pid, :pop
# > returns 5
#
defmodule Stack do
  use GenServer

  def handle_call(:pop, _from, []) do
    { :reply, nil, []}
  end

  def handle_call(:pop, _from, [head | tail]) do
    { :reply, head, tail}
  end

  def handle_cast({:push, value}, current_stack) do
    {:noreply, [ value | current_stack ]}
  end
end