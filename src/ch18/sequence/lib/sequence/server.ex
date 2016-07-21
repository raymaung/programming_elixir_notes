#
# To run in IEX
#
# iex -S mix
# {:ok, pid} = GenServer.start_link Sequence.Server, 100
# GenServer.call pid, :next_number
# GenServer.cast pid, {:increment_number, 10}
# :sys.get_status pid
#
# To reload,
# r Sequence.Server
#
defmodule Sequence.Server do
  use GenServer

  @vsn "0"

  def start_link(stash_pid) do
    {:ok, _pid} = GenServer.start_link(__MODULE__, stash_pid, name: __MODULE__)
  end

  def next_number do
    with next_number = GenServer.call(__MODULE__, :next_number),
    do: "The next number is #{next_number}"
  end

  def increment_number(delta) do
    GenServer.cast __MODULE__, {:increment_number, delta}
  end

  ###########################
  # GenServer implementation
  def init(stash_pid) do
    current_number = Sequence.Stash.get_value stash_pid
    {:ok, {current_number, stash_pid} }
  end

  def handle_call(:next_number, _from, {current_number, stash_pid}) do
    { :reply, current_number, {current_number + 1, stash_pid} }
  end

  def handle_cast({:increment_number, delta}, {current_number, stash_pid}) do
    { :noreply, {current_number + delta, stash_pid} }
  end

  def terminate(_reason, {current_number, stash_pid}) do
    Sequence.Stash.save_value stash_pid, current_number
  end

  #
  # Formatting for :sys.get_status call
  #
  def format_status(_reason, [_pdict, state]) do
    [data: [{'State', "My current state is '#{inspect state}', and I'm happy"}]]
  end
end