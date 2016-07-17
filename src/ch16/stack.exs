#
# Exercise: Compile and Run in IEX
#
# {:ok, pid} = GenServer.start_link Stack, [5, "cat", 9]
# GenServer.call pid, :pop
# > returns 5
#
defmodule Stack do
  use GenServer

  def start_link do
    GenServer.start_link __MODULE__, [], name: __MODULE__
  end

  def pop do
    GenServer.call __MODULE__, :pop
  end

  def push(10) do
    System.halt(10)
  end

  def push(value) do
    GenServer.cast __MODULE__, {:push, value}
  end

  #######
  # GenServer implementation
  def handle_call(:pop, _from, []) do
    { :reply, nil, []}
  end

  def handle_call(:pop, _from, [head | tail]) do
    { :reply, head, tail}
  end

  def handle_cast({:push, value}, current_stack) do
    {:noreply, [ value | current_stack ]}
  end

  def terminate(reason, state) do
    IO.puts reason
    IO.puts state
  end
end